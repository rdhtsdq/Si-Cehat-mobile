import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/services/playlab_storage_service.dart';
import '../../data/models/playlab_score_model.dart';
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

class _PlayLabGameScreenState extends State<PlayLabGameScreen>
    with WidgetsBindingObserver {
  final ApiClient _apiClient = ApiClient.instance;
  WebViewController? _webViewController;

  bool _isInitializingSession = true;
  bool _isLoadingWeb = true;
  bool _hasError = false;
  bool _isDesktopMode = false;
  bool _isExiting = false;
  String? _errorMessage;
  String? _sessionId;
  String? _gameUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrapGameSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _sessionId != null) {
      // User returned from external browser, check if server has recorded completed score
      _fetchServerScore(_sessionId);
    }
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
      String? bToken;
      if (res.isSuccess && res.data != null && res.data['session'] != null) {
        sId = res.data['session']['id']?.toString();
        bToken = res.data['bootstrapToken']?.toString();
      }

      _sessionId = sId;

      // 2. Build target Web Game URL
      final standaloneBase = ApiConstants.gameWebUrl;
      final queryParams = <String, String>{};
      if (bToken != null && bToken.isNotEmpty) queryParams['bootstrap'] = bToken;
      if (sId != null) queryParams['sessionId'] = sId;
      if (childId != null) queryParams['childId'] = childId;

      final uri = Uri.parse(standaloneBase).replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      _gameUrl = uri.toString();

      // Check if native mobile WebView platform is supported (Android/iOS)
      final isMobilePlatform = !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS);

      if (!isMobilePlatform || WebViewPlatform.instance == null) {
        // Desktop (Windows/macOS/Linux) or Web: bypass WebViewController assertion
        if (mounted) {
          setState(() {
            _isDesktopMode = true;
            _isInitializingSession = false;
            _isLoadingWeb = false;
          });
        }
        return;
      }

      // 3. Initialize WebView Controller (Mobile Android/iOS only)
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
              final reqUri = Uri.tryParse(request.url);
              final gameUri = Uri.tryParse(standaloneBase);
              final apiUri = Uri.tryParse(ApiConstants.baseUrl);
              if (reqUri != null) {
                if (reqUri.host == gameUri?.host ||
                    reqUri.host == apiUri?.host ||
                    request.url.startsWith('about:blank') ||
                    request.url.startsWith('sicehat://')) {
                  if (request.url.startsWith('sicehat://exit')) {
                    _exitGame();
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
                }
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
          final sId = data['sessionId']?.toString() ?? _sessionId;
          final scores = data['scores'] as Map<String, dynamic>?;
          // Pre-fetch & cache server score in background
          _fetchServerScore(sId, bridgeScores: scores);
          break;

        case 'EXIT_GAME':
          final sId = data['sessionId']?.toString() ?? _sessionId;
          final scores = data['scores'] as Map<String, dynamic>? ?? {
            if (data['totalScore'] != null) 'totalScore': data['totalScore'],
            if (data['gameplayScore'] != null) 'gameplayScore': data['gameplayScore'],
            if (data['knowledgeScore'] != null) 'knowledgeScore': data['knowledgeScore'],
            if (data['starsEarned'] != null) 'starsEarned': data['starsEarned'],
            if (data['xpAwarded'] != null) 'xpAwarded': data['xpAwarded'],
          };
          _exitGame(sessionId: sId, bridgeScores: scores);
          break;

        default:
          debugPrint('[PlayLabBridge] Unknown message: $rawJson');
      }
    } catch (e) {
      debugPrint('[PlayLabBridge] Error decoding message: $e');
    }
  }

  Future<PlayLabScoreResult?> _fetchServerScore(
    String? sessionId, {
    Map<String, dynamic>? bridgeScores,
  }) async {
    final activeChild = mounted ? context.read<ProfileProvider>().activeChild : null;

    // 1. Query the authoritative server score endpoint
    if (sessionId != null && sessionId.isNotEmpty && sessionId != 'local-simulation') {
      try {
        final res = await _apiClient.get(ApiConstants.gameSessionResult(sessionId));
        if (res.isSuccess && res.data != null && res.data['result'] != null) {
          final serverResult = res.data['result'] as Map<String, dynamic>;

          final scoreResult = PlayLabScoreResult(
            sessionId: sessionId,
            childId: activeChild?.id?.toString(),
            childName: activeChild?.name,
            gameplayScore: (serverResult['gameplayScore'] as num?)?.toInt() ??
                (bridgeScores?['gameplayScore'] as num?)?.toInt() ?? 0,
            knowledgeScore: (serverResult['knowledgeScore'] as num?)?.toInt() ??
                (bridgeScores?['knowledgeScore'] as num?)?.toInt() ?? 0,
            totalScore: (serverResult['totalScore'] as num?)?.toInt() ??
                (bridgeScores?['totalScore'] as num?)?.toInt() ?? 0,
            starsEarned: (serverResult['starsEarned'] as num?)?.toInt() ??
                (bridgeScores?['starsEarned'] as num?)?.toInt() ?? 1,
            xpAwarded: (serverResult['xpAwarded'] as num?)?.toInt() ??
                (bridgeScores?['xpAwarded'] as num?)?.toInt() ?? 0,
            feedbackSummary: serverResult['feedbackSummary']?.toString() ??
                'Hebat! Piring makan ${activeChild?.name ?? "kamu"} berhasil tersusun dengan gizi seimbang.',
          );

          await PlayLabStorageService.instance.saveScoreResult(scoreResult);
          try {
            if (mounted) {
              context.read<ProfileProvider>().loadProfiles();
            }
          } catch (_) {}

          return scoreResult;
        }
      } catch (e) {
        debugPrint('[PlayLab] Failed to fetch server score: $e');
      }
    }

    // 2. Fallback to bridge scores if server request did not return a completed session
    if (bridgeScores != null && bridgeScores.isNotEmpty) {
      final fallback = PlayLabScoreResult(
        sessionId: sessionId ?? 'session-${DateTime.now().millisecondsSinceEpoch}',
        childId: activeChild?.id?.toString(),
        childName: activeChild?.name,
        gameplayScore: (bridgeScores['gameplayScore'] as num?)?.toInt() ?? 0,
        knowledgeScore: (bridgeScores['knowledgeScore'] as num?)?.toInt() ?? 0,
        totalScore: (bridgeScores['totalScore'] as num?)?.toInt() ?? 0,
        starsEarned: (bridgeScores['starsEarned'] as num?)?.toInt() ?? 1,
        xpAwarded: (bridgeScores['xpAwarded'] as num?)?.toInt() ?? 0,
        feedbackSummary: bridgeScores['feedbackSummary']?.toString() ??
            'Permainan Piring Sehat selesai.',
      );

      await PlayLabStorageService.instance.saveScoreResult(fallback);
      try {
        if (mounted) {
          context.read<ProfileProvider>().loadProfiles();
        }
      } catch (_) {}

      return fallback;
    }

    return null;
  }

  Future<void> _exitGame({
    String? sessionId,
    Map<String, dynamic>? bridgeScores,
  }) async {
    if (_isExiting) return;
    _isExiting = true;

    final childId = mounted ? context.read<ProfileProvider>().activeChild?.id?.toString() : null;
    final targetSessionId = sessionId ?? _sessionId;
    PlayLabScoreResult? scoreResult = await _fetchServerScore(
      targetSessionId,
      bridgeScores: bridgeScores,
    );

    // Fallback to locally stored latest score if this child already has one
    scoreResult ??= await PlayLabStorageService.instance.getLatestScore(
      childId: childId,
    );

    if (!mounted) return;
    Navigator.of(context).pop(scoreResult);
  }

  Future<void> _confirmAndExit() async {
    // If score is already available from server, exit directly returning it
    final targetSessionId = _sessionId;
    if (targetSessionId != null) {
      final existingScore = await _fetchServerScore(targetSessionId);
      if (existingScore != null) {
        if (mounted) {
          Navigator.of(context).pop(existingScore);
        }
        return;
      }
    }

    if (!mounted) return;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Permainan?'),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari permainan?',
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
      _exitGame();
    }
  }

  Widget _buildDesktopFallbackView() {
    return Container(
      color: const Color(0xFFFFF9E9),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF173D31), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF173D31),
                  offset: Offset(3, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF75C8E8),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF173D31), width: 2.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.restaurant_menu_rounded, color: Color(0xFF173D31), size: 36),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Piring Sehat Nimbo',
                  style: AppTypography.headingScreen.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mode Desktop Windows Terdeteksi\nWebView native berjalan di Android & iOS. Pada Windows, silakan buka permainan di browser Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF285648),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                if (_sessionId != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF173D31).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'Sesi Aktif: $_sessionId',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF173D31),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_gameUrl != null) {
                        final uri = Uri.parse(_gameUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                    icon: const Icon(Icons.open_in_browser, color: Colors.white),
                    label: const Text(
                      'Buka Game di Browser (Chrome/Edge)',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF247A4D),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await _fetchServerScore(_sessionId);
                      if (result != null) {
                        if (mounted) {
                          Navigator.of(context).pop(result);
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Sesi permainan belum selesai di browser. Silakan selesaikan piring dan kuis di browser terlebih dahulu.',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF247A4D)),
                    label: const Text(
                      'Periksa Skor Server & Selesai',
                      style: TextStyle(color: Color(0xFF247A4D), fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF247A4D), width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
            onPressed: _confirmAndExit,
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
              // 1. ACTIVE WEBVIEW (Mobile Android/iOS)
              if (_webViewController != null && !_hasError && !_isDesktopMode)
                WebViewWidget(controller: _webViewController!),

              // 1b. DESKTOP / WINDOWS FALLBACK
              if (_isDesktopMode && !_isInitializingSession && !_hasError)
                _buildDesktopFallbackView(),

              // 2. LOADING STATE
              if (_isInitializingSession || (_isLoadingWeb && !_hasError && !_isDesktopMode))
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
