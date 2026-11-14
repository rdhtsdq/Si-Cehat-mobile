import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/services/playlab_storage_service.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/calm_widgets.dart';
import '../../data/models/education_model.dart';
import '../../data/models/playlab_score_model.dart';
import '../../providers/app_providers.dart';
import 'education_detail_screen.dart';
import 'playlab_game_screen.dart';
import 'pustaka_edukasi_screen.dart';
import 'quiz_screen.dart';
import 'widgets/playlab_score_dialog.dart';

class EducationScreen extends ConsumerStatefulWidget {
  final bool showBackButton;

  const EducationScreen({super.key, this.showBackButton = false});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  int _selectedTab = 0; // 0: Video, 1: Podcast, 2: Quiz, 3: Pustaka
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
      final activeChild = ref.read(profileProvider).activeChild;
      final score = await PlayLabStorageService.instance.getLatestScore(
        childId: activeChild?.id?.toString(),
      );
      if (mounted) {
        setState(() => _latestPlayLabScore = score);
      }
    } catch (_) {}
  }

  Future<void> _launchPlayLabGame() async {
    final res = await Navigator.of(context).push<PlayLabScoreResult?>(
      MaterialPageRoute(builder: (_) => const PlayLabGameScreen()),
    );
    if (!mounted) return;
    await _loadPlayLabScore();
    if (!mounted) return;
    if (res != null) {
      PlayLabScoreDialog.show(
        context,
        result: res,
        onPlayAgain: _launchPlayLabGame,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eduProv = ref.watch(educationProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          if (widget.showBackButton)
            AppHeader(
              compact: true,
              title: 'Edukasi',
              onBack: () => Navigator.of(context).maybePop(),
            )
          else
            const AppHeader(
              title: 'Edukasi',
              subtitle: 'Belajar sehat bersama si Kecil',
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.md,
                AppSpacing.pageGutter,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlayLabBanner(context),
                  const SizedBox(height: AppSpacing.md),
                  SegmentedPills(
                    labels: const ['Video', 'Podcast', 'Quiz', 'Pustaka'],
                    selectedIndex: _selectedTab,
                    onSelected: (index) => setState(() => _selectedTab = index),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: _selectedTab == 3
                        ? const PustakaEdukasiScreen(showAppBar: false)
                        : (_selectedTab == 2
                              ? _buildQuizPromptCard(context)
                              : _buildMediaList(
                                  context,
                                  _selectedTab == 0
                                      ? eduProv.getVideos()
                                      : eduProv.getPodcasts(),
                                )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayLabBanner(BuildContext context) {
    final hasScore = _latestPlayLabScore != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primarySoft2,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppRadius.button,
                          ),
                          child: Text(
                            'PlayLab Game',
                            style: AppTypography.micro.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (hasScore) ...[
                          const SizedBox(width: 6),
                          for (var i = 0; i < 3; i++)
                            Icon(
                              i < _latestPlayLabScore!.starsEarned
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 15,
                              color: i < _latestPlayLabScore!.starsEarned
                                  ? AppColors.warning
                                  : AppColors.chipNeutralFg,
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Piring Sehat Nimbo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasScore
                          ? 'Skor Terakhir: ${_latestPlayLabScore!.totalScore}/100 · +${_latestPlayLabScore!.xpAwarded} XP'
                          : 'Susun variasi makanan seimbang & kuis!',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: hasScore
                            ? AppColors.primary
                            : AppColors.textMuted,
                        fontWeight: hasScore
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (hasScore) ...[
                Expanded(
                  child: GhostButton(
                    label: 'Lihat Nilai',
                    icon: Icons.analytics_outlined,
                    height: 36,
                    expanded: true,
                    onPressed: () {
                      PlayLabScoreDialog.show(
                        context,
                        result: _latestPlayLabScore!,
                        onPlayAgain: _launchPlayLabGame,
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: AppPillButton(
                  label: hasScore ? 'Main Lagi' : 'Main Sekarang',
                  icon: Icons.sports_esports_outlined,
                  height: 36,
                  onPressed: _launchPlayLabGame,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaList(BuildContext context, List<EducationModel> items) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.video_library_outlined,
        title: 'Belum ada materi',
        message: 'Belum ada materi pada kategori ini.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = items[index];
        final isVideo = item.type == 'video';
        final ytThumb = item.youtubeThumbnailUrl;

        return AppCard(
          padding: const EdgeInsets.all(10),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EducationDetailScreen(item: item),
              ),
            );
          },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: SizedBox(
                  width: 96,
                  height: 64,
                  child: isVideo && ytThumb != null && ytThumb.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              ytThumb,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: AppColors.chipNeutralBg,
                                child: const Icon(
                                  Icons.play_circle_outline_rounded,
                                  color: AppColors.chipNeutralFg,
                                  size: 28,
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: AppColors.onPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          color: AppColors.chipNeutralBg,
                          child: Icon(
                            isVideo
                                ? Icons.play_circle_outline_rounded
                                : Icons.headphones_outlined,
                            size: 28,
                            color: AppColors.chipNeutralFg,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.duration,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption,
                          ),
                        ),
                        const SizedBox(width: 6),
                        StatusBadge(
                          label: isVideo ? 'Preview Video' : 'Audio',
                          background: isVideo
                              ? AppColors.chipPeachBg
                              : AppColors.primarySoft,
                          foreground: isVideo
                              ? AppColors.chipPeachFg
                              : AppColors.primary,
                          borderColor: null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizPromptCard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 96),
      child: AppCard(
        radius: AppRadius.xl,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const IconChip(
              icon: Icons.quiz_outlined,
              size: 64,
              circle: true,
              background: AppColors.primarySoft,
              foreground: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Uji Pemahaman Hidup Sehat',
              textAlign: TextAlign.center,
              style: AppTypography.h2,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Cek pemahaman Anda mengenai batas gula harian, bekal sehat, dan kebiasaan gerak aktif anak.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppPillButton(
              label: 'Mulai Kuis Sekarang',
              icon: Icons.play_arrow_rounded,
              expanded: false,
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const QuizScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
