import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../providers/profile_provider.dart';

class PlayLabGameScreen extends StatefulWidget {
  final String gameSlug;

  const PlayLabGameScreen({
    super.key,
    this.gameSlug = 'piring-sehat-nimbo',
  });

  @override
  State<PlayLabGameScreen> createState() => _PlayLabGameScreenState();
}

class _PlayLabGameScreenState extends State<PlayLabGameScreen> {
  final ApiClient _apiClient = ApiClient.instance;
  WebViewController? _webViewController;

  bool _isInitializingSession = true;
  bool _isLoadingWeb = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _sessionId;
  String? _gameUrl;

  @override
  void initState() {
    super.initState();
    _bootstrapGameSession();
  }

  Future<void> _bootstrapGameSession() async {
    setState(() {
      _isInitializingSession = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final profileProv = context.read<ProfileProvider>();
      final activeChild = profileProv.activeChild;
      final childId = activeChild?.id.toString();

      // 1. Request session creation from backend
      final res = await _apiClient.post(
        ApiConstants.gameSessions,
        body: {
          'gameSlug': widget.gameSlug,
          if (childId != null && childId.isNotEmpty) 'childId': childId,
          'studyId': 'si-cehat-playlab-eval-2026',
        },
      );

      String? sId;
      if (res.isSuccess && res.data != null && res.data['session'] != null) {
        sId = res.data['session']['id']?.toString();
      }

      _sessionId = sId;

      // 2. Build target Web Game URL
      final base = ApiConstants.baseUrl;
      final queryParams = <String, String>{};
      if (sId != null) queryParams['sessionId'] = sId;
      if (childId != null) queryParams['childId'] = childId;

      final uri = Uri.parse('$base/playlab/piring-sehat').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      _gameUrl = uri.toString();

      // 3. Initialize WebView Controller
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFFFF9E9))
        ..addJavaScriptChannel(
          'PlayLabBridge',
          onMessageReceived: (JavaScriptMessage message) {
            _handleBridgeMessage(message.message);
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              // Security: only allow allowed origin
              if (request.url.startsWith(base)) {
                return NavigationDecision.navigate;
              }
              debugPrint('[PlayLabWebView] Blocked navigation to: ${request.url}');
              return NavigationDecision.prevent;
            },
            onPageStarted: (_) {
              if (mounted) setState(() => _isLoadingWeb = true);
            },
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoadingWeb = false);
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('[PlayLabWebView] ResourceError: ${error.description}');
              if (mounted && (error.isForMainFrame ?? true)) {
                setState(() {
                  _hasError = true;
                  _isLoadingWeb = false;
                  _errorMessage = 'Gagal memuat game PlayLab (${error.description}).';
                });
              }
            },
          ),
        )
        ..loadRequest(uri);

      if (mounted) {
        setState(() {
          _webViewController = controller;
          _isInitializingSession = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializingSession = false;
          _hasError = true;
          _errorMessage = 'Terjadi kesalahan saat memulai sesi game: $e';
        });
      }
    }
  }

  void _handleBridgeMessage(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final type = data['type']?.toString();

      debugPrint('[PlayLabBridge] Received: $type');

      switch (type) {
        case 'GAME_READY':
          if (mounted) setState(() => _isLoadingWeb = false);
          break;

        case 'GAME_COMPLETED':
          _onGameCompleted(data['sessionId']?.toString() ?? _sessionId);
          break;

        case 'EXIT_GAME':
          _forceExit();
          break;

        default:
          debugPrint('[PlayLabBridge] Unknown message: $rawJson');
      }
    } catch (e) {
      debugPrint('[PlayLabBridge] Error decoding message: $e');
    }
  }

  void _forceExit() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _onGameCompleted(String? completedSessionId) async {
    if (completedSessionId == null) {
      Navigator.of(context).maybePop();
      return;
    }

    // Refresh child progress in profile provider
    try {
      context.read<ProfileProvider>().loadProfiles();
    } catch (_) {}

    // Fetch verified result from server
    Map<String, dynamic>? verifiedResult;
    try {
      final res = await _apiClient.get(ApiConstants.gameSessionResult(completedSessionId));
      if (res.isSuccess && res.data != null && res.data['result'] != null) {
        verifiedResult = res.data['result'] as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[PlayLab] Failed to fetch verified result: $e');
    }

    if (!mounted) return;

    final gameplayScore = verifiedResult?['gameplayScore'] ?? 100;
    final knowledgeScore = verifiedResult?['knowledgeScore'] ?? 100;
    final totalScore = verifiedResult?['totalScore'] ?? 100;
    final stars = verifiedResult?['starsEarned'] ?? 3;
    final feedback = verifiedResult?['feedbackSummary'] ??
        'Selamat! Kamu telah menyelesaikan permainan Piring Sehat Nimbo!';
    final xpAwarded = verifiedResult?['xpAwarded'] ?? 75;

    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (idx) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      idx < stars ? Icons.star_rounded : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 42,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Text(
                'Permainan Selesai!',
                style: AppTypography.headingScreen.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                feedback,
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 16),

              // XP Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.veryLightGreen,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGreen.withAlpha(100)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, color: AppColors.primaryGreenDark, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '+$xpAwarded XP Edukasi Berhasil Diraih',
                      style: AppTypography.badgeText.copyWith(
                        color: AppColors.primaryGreenDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Scores comparison container
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.fieldBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withAlpha(15)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Skor Gameplay Piring:'),
                        Text(
                          '$gameplayScore / 100',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Skor Pengetahuan:'),
                        Text(
                          '$knowledgeScore / 100',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Skor Validasi Server:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '$totalScore / 100',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreenDark,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Return CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _forceExit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Kembali ke Si-Cehat',
                    style: AppTypography.buttonText.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmAndExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Permainan?'),
        content: const Text(
          'Progres menyusun piring belum tersimpan jika kamu keluar sekarang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Lanjut Bermain'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      _forceExit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeChild = context.watch<ProfileProvider>().activeChild;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _confirmAndExit();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF9E9),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF9E9),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 26),
            tooltip: 'Kembali',
            onPressed: _forceExit,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PlayLab: Piring Sehat Nimbo',
                style: AppTypography.headingScreen.copyWith(fontSize: 16),
              ),
              if (activeChild != null)
                Text(
                  'Peserta: ${activeChild.name}',
                  style: AppTypography.bodySecondary.copyWith(
                    fontSize: 11,
                    color: AppColors.primaryGreenDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textDark),
              tooltip: 'Muat Ulang Permainan',
              onPressed: () {
                if (_webViewController != null && _gameUrl != null) {
                  _webViewController!.loadRequest(Uri.parse(_gameUrl!));
                } else {
                  _bootstrapGameSession();
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // 1. ACTIVE WEBVIEW
              if (_webViewController != null && !_hasError)
                WebViewWidget(controller: _webViewController!),

              // 2. LOADING STATE
              if (_isInitializingSession || (_isLoadingWeb && !_hasError))
                Container(
                  color: const Color(0xFFFFF9E9),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryGreen, width: 2),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isInitializingSession
                            ? 'Menyiapkan Sesi PlayLab...'
                            : 'Memuat Permainan Piring Sehat...',
                          style: AppTypography.titleCard.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Menghubungkan ke server riset Si-Cehat',
                          style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. ERROR STATE
              if (_hasError)
                Container(
                  color: const Color(0xFFFFF9E9),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 54, color: Colors.orange),
                        const SizedBox(height: 16),
                        Text(
                          'Koneksi PlayLab Terputus',
                          style: AppTypography.headingScreen.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage ??
                              'Tidak dapat terhubung ke server permainan. Pastikan server Si-Cehat aktif.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySecondary.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _bootstrapGameSession,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
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
