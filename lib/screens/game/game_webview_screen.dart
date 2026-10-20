import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/constants/colors.dart';
import '../../providers/profile_provider.dart';

class GameWebviewScreen extends StatefulWidget {
  final String? childId;
  final String? childName;

  const GameWebviewScreen({
    super.key,
    this.childId,
    this.childName,
  });

  @override
  State<GameWebviewScreen> createState() => _GameWebviewScreenState();
}

class _GameWebviewScreenState extends State<GameWebviewScreen> {
  final ApiClient _apiClient = ApiClient.instance;

  WebViewController? _webViewController;
  bool _isLoading = true;
  String? _errorMessage;
  String? _sessionId;
  String? _bootstrapToken;

  @override
  void initState() {
    super.initState();
    _startAuthorizedGameSession();
  }

  Future<void> _startAuthorizedGameSession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Request authorized game session and short-lived bootstrap token from backend
      final res = await _apiClient.post(
        ApiConstants.gameSessions,
        body: {
          'gameSlug': 'piring-sehat-nimbo',
          if (widget.childId != null && widget.childId!.isNotEmpty)
            'childId': widget.childId,
        },
      );

      if (res.isSuccess && res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        final session = data['session'] as Map<String, dynamic>?;
        _sessionId = session?['id']?.toString();
        _bootstrapToken = data['bootstrapToken']?.toString();

        _initializeWebViewController();
      } else {
        // Fallback to direct URL if session endpoint is unreachable
        _initializeWebViewController();
      }
    } catch (e) {
      debugPrint('[GameWebviewScreen] Session bootstrap error: $e');
      _initializeWebViewController();
    }
  }

  void _initializeWebViewController() {
    final baseUrl = ApiConstants.gameWebUrl;
    final queryParams = <String, String>{};

    if (_bootstrapToken != null && _bootstrapToken!.isNotEmpty) {
      queryParams['bootstrap'] = _bootstrapToken!;
    }
    if (_sessionId != null && _sessionId!.isNotEmpty) {
      queryParams['sessionId'] = _sessionId!;
    }
    if (widget.childId != null && widget.childId!.isNotEmpty) {
      queryParams['childId'] = widget.childId!;
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFF9E9))
      ..addJavaScriptChannel(
        'PlayLabBridge',
        onMessageReceived: (JavaScriptMessage jsMessage) {
          _handleBridgeMessage(jsMessage.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted && _isLoading) {
              // Hide spinner once page is ready
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('[PlayLab WebView] Resource error: ${error.description}');
            if (mounted && _isLoading) {
              setState(() {
                _errorMessage =
                    'Tidak dapat memuat game. Pastikan server web aktif pada $baseUrl';
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Strict origin allowlist check
            final reqUri = Uri.tryParse(request.url);
            final targetUri = Uri.tryParse(baseUrl);
            if (reqUri != null && targetUri != null) {
              if (reqUri.host == targetUri.host ||
                  request.url.startsWith('about:blank')) {
                return NavigationDecision.navigate;
              }
            }
            debugPrint('[PlayLab WebView] Blocked unauthorized navigation: ${request.url}');
            return NavigationDecision.prevent;
          },
        ),
      );

    controller.loadRequest(uri);

    setState(() {
      _webViewController = controller;
    });
  }

  void _handleBridgeMessage(String rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage);
      if (decoded is! Map<String, dynamic>) return;

      final type = decoded['type'] as String?;

      switch (type) {
        case 'GAME_READY':
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          break;

        case 'GAME_COMPLETED':
          debugPrint('[PlayLab WebView] Game completed: $decoded');
          // Invalidate profile & reload progress in background so XP refreshes
          if (mounted) {
            context.read<ProfileProvider>().loadProfiles();
          }
          break;

        case 'EXIT_GAME':
          if (mounted) {
            Navigator.of(context).pop();
          }
          break;

        default:
          debugPrint('[PlayLab WebView] Unknown bridge message type: $type');
      }
    } catch (e) {
      debugPrint('[PlayLab WebView] Failed to parse bridge message: $e');
    }
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF9E9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF173D31), width: 2),
        ),
        title: const Text(
          'Keluar dari Game?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF173D31),
          ),
        ),
        content: const Text(
          'Piring sehatmu belum selesai tersusun. Mau lanjut bermain?',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF285648),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Lanjut Main',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final ok = await _onWillPop();
        if (ok && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF9E9),
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Web View Host
              if (_webViewController != null && _errorMessage == null)
                WebViewWidget(controller: _webViewController!),

              // 2. Loading State
              if (_isLoading && _errorMessage == null)
                Container(
                  color: const Color(0xFFFFF9E9),
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF75C8E8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF173D31),
                              width: 3,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant_menu_rounded,
                              color: Color(0xFF173D31),
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Menyiapkan Piring Sehat Nimbo...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF173D31),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(
                          width: 140,
                          child: LinearProgressIndicator(
                            color: Color(0xFF247A4D),
                            backgroundColor: Color(0xFFE2E8F0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. Error Fallback State
              if (_errorMessage != null)
                Container(
                  color: const Color(0xFFFFF9E9),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 48,
                          color: Color(0xFFE05252),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Gagal Membuka Game',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF173D31),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF285648),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _startAuthorizedGameSession,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF247A4D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Kembali ke Menu'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
