import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../data/models/education_model.dart';

class EducationDetailScreen extends StatefulWidget {
  final EducationModel item;

  const EducationDetailScreen({super.key, required this.item});

  @override
  State<EducationDetailScreen> createState() => _EducationDetailScreenState();
}

class _EducationDetailScreenState extends State<EducationDetailScreen> {
  // Audio Player State for Podcasts
  AudioPlayer? _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = 1.0;
  bool _isAudioLoading = false;
  String? _audioErrorMessage;

  StreamSubscription? _stateSub;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;

  @override
  void initState() {
    super.initState();
    if (widget.item.type == 'podcast') {
      _initAudioPlayer();
    }
  }

  void _initAudioPlayer() {
    try {
      _audioPlayer = AudioPlayer();

      _stateSub = _audioPlayer?.onPlayerStateChanged.listen((state) {
        if (mounted) setState(() => _playerState = state);
      });

      _posSub = _audioPlayer?.onPositionChanged.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });

      _durSub = _audioPlayer?.onDurationChanged.listen((dur) {
        if (mounted) setState(() => _duration = dur);
      });
    } catch (e) {
      debugPrint('[AudioPlayer] Init error: $e');
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _audioPlayer?.stop();
    _audioPlayer?.dispose();
    super.dispose();
  }

  String? _extractYouTubeId(String? url) {
    if (url == null || url.isEmpty) return null;
    final regExp = RegExp(
      r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))([\w-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  Future<void> _launchMediaUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan media.')),
        );
      }
    }
  }

  Future<void> _toggleAudioPlay() async {
    if (_audioPlayer == null) return;
    final audioUrl = widget.item.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan audio podcast belum tersedia.')),
      );
      return;
    }

    try {
      setState(() {
        _isAudioLoading = true;
        _audioErrorMessage = null;
      });

      if (_playerState == PlayerState.playing) {
        await _audioPlayer?.pause();
      } else {
        await _audioPlayer?.play(UrlSource(audioUrl));
        await _audioPlayer?.setPlaybackRate(_playbackSpeed);
      }
    } catch (e) {
      setState(() => _audioErrorMessage = 'Gagal memuat audio: $e');
    } finally {
      if (mounted) setState(() => _isAudioLoading = false);
    }
  }

  Future<void> _seekRelative(int seconds) async {
    if (_audioPlayer == null) return;
    final newPos = _position + Duration(seconds: seconds);
    final target = newPos < Duration.zero
        ? Duration.zero
        : (_duration > Duration.zero && newPos > _duration ? _duration : newPos);
    await _audioPlayer?.seek(target);
  }

  void _cyclePlaybackSpeed() async {
    final speeds = [1.0, 1.25, 1.5, 2.0];
    final nextIndex = (speeds.indexOf(_playbackSpeed) + 1) % speeds.length;
    final newSpeed = speeds[nextIndex];
    setState(() => _playbackSpeed = newSpeed);
    await _audioPlayer?.setPlaybackRate(newSpeed);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isVideo = item.type == 'video';
    final isPodcast = item.type == 'podcast';
    final ytId = _extractYouTubeId(item.videoUrl);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.headingScreen.copyWith(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. MEDIA PLAYER SECTION
              // ==========================================
              if (isVideo)
                _buildVideoPlayerSection(item, ytId)
              else if (isPodcast)
                _buildPodcastPlayerSection(item)
              else
                _buildArticleBannerSection(item),

              const SizedBox(height: 18),

              // Title & Category Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isVideo
                          ? Colors.purple.shade50
                          : isPodcast
                              ? Colors.amber.shade50
                              : AppColors.veryLightGreen,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isVideo
                            ? Colors.purple.shade200
                            : isPodcast
                                ? Colors.amber.shade200
                                : AppColors.primaryGreen.withAlpha(80),
                      ),
                    ),
                    child: Text(
                      isVideo
                          ? '🎬 Video Edukasi'
                          : isPodcast
                              ? '🎙️ Podcast Audio'
                              : '📄 Artikel Sehat',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isVideo
                            ? Colors.purple.shade800
                            : isPodcast
                                ? Colors.amber.shade900
                                : AppColors.primaryGreenDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                item.title,
                style: AppTypography.headingScreen.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.speakerOrSource,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    item.duration,
                    style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Summary Section
              Text(
                'Ringkasan Materi:',
                style: AppTypography.titleCard.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.veryLightGreen,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGreen.withAlpha(60)),
                ),
                child: Text(
                  item.summary,
                  style: AppTypography.bodyRegular.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreenDark,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Content Body / Transcript Section
              Text(
                isPodcast ? 'Transkrip & Catatan Diskusi:' : 'Konten Panduan:',
                style: AppTypography.titleCard.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                item.contentBody,
                style: AppTypography.bodyRegular.copyWith(
                  height: 1.6,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: VIDEO PLAYER SECTION
  // ==========================================
  Widget _buildVideoPlayerSection(EducationModel item, String? ytId) {
    final videoUrl = item.videoUrl ?? 'https://www.youtube.com/watch?v=kXYiU_JCYtU';
    final thumbnailUrl = ytId != null
        ? 'https://img.youtube.com/vi/$ytId/hqdefault.jpg'
        : (item.imageUrl ?? '');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Thumbnail Image
            if (thumbnailUrl.isNotEmpty)
              Image.network(
                thumbnailUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Icon(Icons.movie_outlined, size: 48, color: Colors.white54),
                  ),
                ),
              )
            else
              Container(
                color: Colors.black87,
                child: const Center(
                  child: Icon(Icons.movie_outlined, size: 48, color: Colors.white54),
                ),
              ),

            // Semi-transparent overlay
            Container(color: Colors.black.withAlpha(90)),

            // Big Play Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _launchMediaUrl(videoUrl),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withAlpha(100),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Bottom banner with action
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(180),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle, color: Colors.redAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          ytId != null ? 'YouTube Video' : 'Video Tutorial',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _launchMediaUrl(videoUrl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Putar Video ↗',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
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

  // ==========================================
  // WIDGET: PODCAST AUDIO PLAYER SECTION
  // ==========================================
  Widget _buildPodcastPlayerSection(EducationModel item) {
    final isPlaying = _playerState == PlayerState.playing;
    final isSpotify = item.mediaType == 'spotify' || (item.audioUrl?.contains('spotify') ?? false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade50,
            Colors.orange.shade50.withAlpha(150),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade100.withAlpha(100),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Icon + Title
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.orange.shade500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.podcasts, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.speakerOrSource,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSpotify)
                IconButton(
                  icon: Text(
                    '${_playbackSpeed}x',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  tooltip: 'Kecepatan Putar',
                  onPressed: _cyclePlaybackSpeed,
                ),
            ],
          ),

          const SizedBox(height: 16),

          if (isSpotify) ...[
            // Spotify CTA
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954).withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1DB954).withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.music_note, color: Color(0xFF1DB954), size: 24),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Tersedia di Spotify Podcast',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF138A3C)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _launchMediaUrl(item.audioUrl ?? 'https://open.spotify.com'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      elevation: 0,
                    ),
                    child: const Text('Buka ↗', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Audio Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                activeTrackColor: Colors.orange.shade600,
                inactiveTrackColor: Colors.orange.shade100,
                thumbColor: Colors.orange.shade700,
              ),
              child: Slider(
                value: _duration.inSeconds > 0
                    ? _position.inSeconds.clamp(0, _duration.inSeconds).toDouble()
                    : 0.0,
                max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                onChanged: (val) {
                  _audioPlayer?.seek(Duration(seconds: val.toInt()));
                },
              ),
            ),

            // Time Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(_position),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _duration > Duration.zero ? _formatDuration(_duration) : item.duration,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Controls Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10, size: 28),
                  color: Colors.orange.shade900,
                  tooltip: 'Mundur 10 Detik',
                  onPressed: () => _seekRelative(-10),
                ),
                const SizedBox(width: 14),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isAudioLoading ? null : _toggleAudioPlay,
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade600, Colors.amber.shade600],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withAlpha(90),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isAudioLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 38,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                IconButton(
                  icon: const Icon(Icons.forward_10, size: 28),
                  color: Colors.orange.shade900,
                  tooltip: 'Maju 10 Detik',
                  onPressed: () => _seekRelative(10),
                ),
              ],
            ),

            if (_audioErrorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _audioErrorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 11),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: ARTICLE BANNER SECTION
  // ==========================================
  Widget _buildArticleBannerSection(EducationModel item) {
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          item.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackBanner(),
        ),
      );
    }
    return _buildFallbackBanner();
  }

  Widget _buildFallbackBanner() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.veryLightGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withAlpha(50)),
      ),
      child: const Center(
        child: Icon(Icons.menu_book_rounded, size: 48, color: AppColors.primaryGreenDark),
      ),
    );
  }
}
