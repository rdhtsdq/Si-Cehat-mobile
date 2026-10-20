import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../constants/colors.dart';

class YouTubeEmbeddedPlayer extends StatefulWidget {
  final String videoUrl;
  final String? videoId;
  final String? title;
  final String? fallbackThumbnail;
  final bool startPlaying;
  final VoidCallback? onPlaybackStarted;

  const YouTubeEmbeddedPlayer({
    super.key,
    required this.videoUrl,
    this.videoId,
    this.title,
    this.fallbackThumbnail,
    this.startPlaying = false,
    this.onPlaybackStarted,
  });

  @override
  State<YouTubeEmbeddedPlayer> createState() => _YouTubeEmbeddedPlayerState();
}

class _YouTubeEmbeddedPlayerState extends State<YouTubeEmbeddedPlayer> {
  WebViewController? _webViewController;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  String? get _resolvedVideoId {
    if (widget.videoId != null && widget.videoId!.isNotEmpty) {
      return widget.videoId;
    }
    return _extractYouTubeId(widget.videoUrl);
  }

  static String? _extractYouTubeId(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final clean = url.trim();

    if (RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(clean)) {
      return clean;
    }

    final regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.|m\.)?(?:youtube(?:-nocookie)?\.com\/(?:watch\?(?:.*&)?v=|embed\/|v\/|shorts\/|live\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(clean);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    try {
      final uri = Uri.tryParse(clean);
      if (uri != null && uri.queryParameters.containsKey('v')) {
        final v = uri.queryParameters['v'];
        if (v != null && v.length == 11) return v;
      }
    } catch (_) {}

    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.startPlaying) {
      _startEmbeddedPlayer();
    }
  }

  void _startEmbeddedPlayer() {
    final vId = _resolvedVideoId;
    if (vId == null) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Tautan video YouTube tidak valid.';
      });
      return;
    }

    setState(() {
      _isPlaying = true;
      _isLoading = true;
      _hasError = false;
    });

    widget.onPlaybackStarted?.call();

    try {
      final embedHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; background-color: #000; }
    html, body { width: 100%; height: 100%; overflow: hidden; display: flex; justify-content: center; align-items: center; }
    iframe { width: 100%; height: 100%; border: none; }
  </style>
</head>
<body>
  <iframe 
    src="https://www.youtube-nocookie.com/embed/$vId?autoplay=1&playsinline=1&rel=0&modestbranding=1&enablejsapi=1" 
    frameborder="0" 
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" 
    allowfullscreen>
  </iframe>
</body>
</html>
''';

      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (error) {
              debugPrint('[YouTubePlayer] WebResourceError: ${error.description}');
              if (mounted) {
                // If main frame error
                if (error.isForMainFrame ?? true) {
                  setState(() {
                    _isLoading = false;
                    _hasError = true;
                    _errorMessage = 'Gagal memuat pemutar video (${error.description}).';
                  });
                }
              }
            },
          ),
        )
        ..loadHtmlString(embedHtml, baseUrl: 'https://www.youtube-nocookie.com');
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan pemutar: $e';
      });
    }
  }

  void _stopEmbeddedPlayer() {
    setState(() {
      _isPlaying = false;
      _isLoading = false;
      _hasError = false;
      _webViewController = null;
    });
  }

  Future<void> _openExternalYouTube() async {
    final vId = _resolvedVideoId;
    final targetUrl = vId != null
        ? 'https://www.youtube.com/watch?v=$vId'
        : widget.videoUrl;
    final uri = Uri.tryParse(targetUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi YouTube.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vId = _resolvedVideoId;
    final thumbnailUrl = vId != null
        ? 'https://img.youtube.com/vi/$vId/hqdefault.jpg'
        : (widget.fallbackThumbnail ?? '');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. ACTIVE WEBVIEW PLAYER
            if (_isPlaying && _webViewController != null && !_hasError)
              Positioned.fill(
                child: WebViewWidget(controller: _webViewController!),
              ),

            // 2. LOADING STATE OVERLAY
            if (_isPlaying && _isLoading && !_hasError)
              Container(
                color: Colors.black.withAlpha(180),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.redAccent,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Menghubungkan ke YouTube...',
                        style: TextStyle(
                          color: Colors.white.withAlpha(220),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 3. ERROR STATE
            if (_hasError)
              Container(
                color: Colors.black87,
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.orangeAccent, size: 36),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage ?? 'Gagal memuat video preview.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _startEmbeddedPlayer,
                            icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                            label: const Text('Coba Lagi', style: TextStyle(color: Colors.white, fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _openExternalYouTube,
                            icon: const Icon(Icons.open_in_new, size: 16, color: Colors.white),
                            label: const Text('Buka di YouTube', style: TextStyle(color: Colors.white, fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // 4. COVER PREVIEW MODE (When not yet playing)
            if (!_isPlaying && !_hasError) ...[
              // Thumbnail
              if (thumbnailUrl.isNotEmpty)
                Image.network(
                  thumbnailUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF1E293B),
                    child: const Center(
                      child: Icon(Icons.movie_outlined, size: 54, color: Colors.white38),
                    ),
                  ),
                )
              else
                Container(
                  color: const Color(0xFF1E293B),
                  child: const Center(
                    child: Icon(Icons.movie_outlined, size: 54, color: Colors.white38),
                  ),
                ),

              // Gradient Overlay for readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(50),
                      Colors.black.withAlpha(120),
                    ],
                  ),
                ),
              ),

              // Big Pulsing Play Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _startEmbeddedPlayer,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withAlpha(120),
                          blurRadius: 18,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Top Right Badge: "YouTube Video"
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(180),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.ondemand_video, color: Colors.redAccent, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        vId != null ? 'YouTube Video' : 'Video Tutorial',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Banner with title and quick actions
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Putar Langsung CTA
                    GestureDetector(
                      onTap: _startEmbeddedPlayer,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withAlpha(100),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle_fill, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Putar Video',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // External YouTube launcher button
                    GestureDetector(
                      onTap: _openExternalYouTube,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(190),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white30, width: 0.8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_new, color: Colors.white70, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'Buka YouTube',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 5. Active Controls Overlay (When playing)
            if (_isPlaying && !_hasError)
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stop / Return to Cover button
                    GestureDetector(
                      onTap: _stopEmbeddedPlayer,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(200),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24, width: 0.5),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.stop_circle_outlined, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Tutup Player',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // External link button
                    GestureDetector(
                      onTap: _openExternalYouTube,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(200),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white24, width: 0.5),
                        ),
                        child: const Icon(
                          Icons.open_in_new,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
