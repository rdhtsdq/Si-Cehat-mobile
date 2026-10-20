import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../data/models/education_model.dart';
import '../../data/models/playlab_score_model.dart';
import '../../core/services/playlab_storage_service.dart';
import '../../providers/education_provider.dart';
import '../../providers/profile_provider.dart';
import 'education_detail_screen.dart';
import 'quiz_screen.dart';
import 'pustaka_edukasi_screen.dart';
import 'playlab_game_screen.dart';
import 'widgets/playlab_score_dialog.dart';

class EducationScreen extends StatefulWidget {
  final bool showBackButton;

  const EducationScreen({super.key, this.showBackButton = false});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  int _selectedTab = 0; // 0: Video, 1: Podcast, 2: Quiz
  PlayLabScoreResult? _latestPlayLabScore;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlayLabScore();
    });
  }

  Future<void> _loadPlayLabScore() async {
    try {
      final activeChild = context.read<ProfileProvider>().activeChild;
      final score = await PlayLabStorageService.instance.getLatestScore(
        childId: activeChild?.id?.toString(),
      );
      if (mounted) {
        setState(() => _latestPlayLabScore = score);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final eduProv = context.watch<EducationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(
          'Edukasi',
          style: AppTypography.headingScreen.copyWith(fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book, color: AppColors.primaryGreenDark),
            tooltip: 'Pustaka Edukasi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PustakaEdukasiScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. PlayLab Mini-Game Banner
              _buildPlayLabBanner(context),

              // 2. Empat tab: Video, Podcast, Quiz, Pustaka Edukasi
              Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      title: 'Video',
                      isActive: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildTabButton(
                      title: 'Podcast',
                      isActive: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildTabButton(
                      title: 'Quiz',
                      isActive: _selectedTab == 2,
                      onTap: () => setState(() => _selectedTab = 2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildTabButton(
                      title: 'Pustaka',
                      isActive: _selectedTab == 3,
                      onTap: () => setState(() => _selectedTab = 3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Daftar konten edukasi
              Expanded(
                child: _selectedTab == 3
                    ? const PustakaEdukasiScreen(showAppBar: false)
                    : (_selectedTab == 2
                        ? _buildQuizPromptCard(context)
                        : _buildMediaList(
                            context,
                            _selectedTab == 0 ? eduProv.getVideos() : eduProv.getPodcasts(),
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayLabBanner(BuildContext context) {
    final hasScore = _latestPlayLabScore != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFF7D6),
            const Color(0xFFDCFCE7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withAlpha(90), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGreen, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.restaurant_menu_rounded, color: AppColors.primaryGreen, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PlayLab Game',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (hasScore) ...[
                          const SizedBox(width: 6),
                          Row(
                            children: List.generate(3, (idx) {
                              final isEarned = idx < _latestPlayLabScore!.starsEarned;
                              return Icon(
                                isEarned ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 16,
                                color: isEarned ? const Color(0xFFF59E0B) : Colors.grey.shade400,
                              );
                            }),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Piring Sehat Nimbo',
                      style: AppTypography.titleCard.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      hasScore
                          ? 'Skor Terakhir: ${_latestPlayLabScore!.totalScore}/100 • +${_latestPlayLabScore!.xpAwarded} XP'
                          : 'Susun variasi makanan seimbang & kuis!',
                      style: AppTypography.bodySecondary.copyWith(
                        fontSize: 11,
                        fontWeight: hasScore ? FontWeight.bold : FontWeight.normal,
                        color: hasScore ? const Color(0xFF166534) : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (hasScore) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      PlayLabScoreDialog.show(
                        context,
                        result: _latestPlayLabScore!,
                        onPlayAgain: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PlayLabGameScreen()),
                          );
                          _loadPlayLabScore();
                        },
                      );
                    },
                    icon: const Icon(Icons.analytics_outlined, size: 16, color: Color(0xFF173D31)),
                    label: const Text(
                      'Lihat Nilai',
                      style: TextStyle(color: Color(0xFF173D31), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF173D31), width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PlayLabGameScreen()),
                    );
                    _loadPlayLabScore();
                  },
                  icon: const Icon(Icons.sports_esports_rounded, size: 16, color: Colors.white),
                  label: Text(
                    hasScore ? 'Main Lagi' : 'Main Sekarang',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreenDark,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? AppColors.primaryGreen : AppColors.fieldBackground,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTypography.buttonText.copyWith(
              color: isActive ? Colors.white : AppColors.textDark,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaList(BuildContext context, List<EducationModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_library_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'Belum ada materi pada kategori ini.',
                style: AppTypography.bodySecondary,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = items[index];
        final isVideo = item.type == 'video';
        final ytThumb = item.youtubeThumbnailUrl;

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EducationDetailScreen(item: item),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  // Thumbnail Preview
                  if (isVideo && ytThumb != null && ytThumb.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 88,
                        height: 66,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              ytThumb,
                              width: 88,
                              height: 66,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: AppColors.paleGreenBg,
                                child: const Icon(Icons.play_circle_outline, color: AppColors.primaryGreenDark, size: 32),
                              ),
                            ),
                            Container(color: Colors.black.withAlpha(50)),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 4),
                                ],
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                            ),
                            Positioned(
                              bottom: 3,
                              right: 3,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(190),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  'YOUTUBE',
                                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 66,
                      decoration: BoxDecoration(
                        color: isVideo ? Colors.purple.shade50 : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isVideo ? Colors.purple.shade200 : Colors.amber.shade200,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isVideo ? Icons.play_circle_outline : Icons.headphones_outlined,
                          size: 32,
                          color: isVideo ? Colors.purple.shade700 : Colors.amber.shade800,
                        ),
                      ),
                    ),
                  const SizedBox(width: 14),

                  // Title bold, duration & badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTypography.titleCard.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              item.duration,
                              style: AppTypography.bodySecondary.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isVideo ? Colors.red.shade50 : Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isVideo ? 'Preview Video' : 'Audio',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isVideo ? Colors.red.shade700 : Colors.amber.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizPromptCard(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.paleGreenBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.quiz_outlined, size: 64, color: AppColors.primaryGreenDark),
            const SizedBox(height: 16),
            Text(
              'Uji Pemahaman Hidup Sehat',
              style: AppTypography.titleCard.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Cek pemahaman Anda mengenai batas gula harian, bekal sehat, dan kebiasaan gerak aktif anak.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuizScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Mulai Kuis Sekarang',
                style: AppTypography.buttonText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
