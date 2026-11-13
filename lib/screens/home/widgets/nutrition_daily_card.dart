import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/calm_widgets.dart';
import '../../../providers/app_providers.dart';

/// Daily nutrition progress card shown on the Home screen.
///
/// Shows today's calorie intake vs the child's target with a shortcut to
/// capture and analyse a meal photo directly from Home.
class NutritionDailyCard extends ConsumerStatefulWidget {
  final String? childId;
  final VoidCallback onPhoto;
  final VoidCallback onDetail;

  const NutritionDailyCard({
    super.key,
    required this.childId,
    required this.onPhoto,
    required this.onDetail,
  });

  @override
  ConsumerState<NutritionDailyCard> createState() => _NutritionDailyCardState();
}

class _NutritionDailyCardState extends ConsumerState<NutritionDailyCard> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant NutritionDailyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) _load();
  }

  void _load() {
    final id = widget.childId;
    if (id == null || id.isEmpty) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Future.microtask(() => ref.read(nutritionProvider).loadSummary(id, today));
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = ref.watch(nutritionProvider);
    final summary = nutrition.summary;
    final hasChild = widget.childId != null && widget.childId!.isNotEmpty;

    final totalCal = summary?.totals.caloriesKkal ?? 0;
    final targetCal =
        summary?.target.caloriesKkal ?? nutrition.target.values.caloriesKkal;
    final ratio = targetCal <= 0 ? 0.0 : (totalCal / targetCal).clamp(0.0, 1.0);
    final remaining = targetCal - totalCal;

    return Semantics(
      container: true,
      label: 'Asupan Hari Ini',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconChip(
                  icon: Icons.restaurant_rounded,
                  size: 36,
                  background: AppColors.chipPeachBg,
                  foreground: AppColors.chipPeachFg,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Asupan Hari Ini',
                        style: AppTypography.title.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Kalori & gizi dari foto / catatan',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                GhostButton(
                  label: 'Lihat',
                  height: 28,
                  onPressed: widget.onDetail,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (!hasChild)
              Text(
                'Pilih profil anak untuk melihat asupan hariannya.',
                style: AppTypography.caption,
              )
            else ...[
              if (summary == null)
                Text(
                  'Belum ada catatan asupan hari ini.',
                  style: AppTypography.caption,
                )
              else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$totalCal',
                      style: AppTypography.hero.copyWith(fontSize: 28),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '/ $targetCal kkal',
                        style: AppTypography.caption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: AppColors.primarySoft,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ratio >= 1 ? AppColors.riskMediumFg : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  remaining >= 0
                      ? 'Sisa $remaining kkal hari ini'
                      : 'Melebihi target ${-remaining} kkal',
                  style: AppTypography.caption.copyWith(
                    color: remaining >= 0
                        ? AppColors.textMuted
                        : AppColors.riskMediumFg,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppPillButton(
                label: 'Foto Makanan',
                icon: Icons.photo_camera_rounded,
                onPressed: nutrition.isAnalyzingPhoto ? null : widget.onPhoto,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
