import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../theme/app_tokens.dart';

enum BannerType { demo, simulation, offline, notice }

class SafetyBanner extends StatelessWidget {
  final String text;
  final BannerType type;
  final IconData? customIcon;
  final EdgeInsetsGeometry margin;

  const SafetyBanner({
    super.key,
    required this.text,
    this.type = BannerType.demo,
    this.customIcon,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.sm),
  });

  @override
  Widget build(BuildContext context) {
    final (background, border, foreground, icon) = switch (type) {
      BannerType.simulation => (
          AppColors.warningBg,
          AppColors.warning,
          AppColors.chipPeachFg,
          Icons.info_outline_rounded,
        ),
      BannerType.offline => (
          AppColors.primarySoft,
          AppColors.border,
          AppColors.primary,
          Icons.cloud_off_outlined,
        ),
      BannerType.notice => (
          AppColors.chipNeutralBg,
          AppColors.border,
          AppColors.textMuted,
          Icons.help_outline_rounded,
        ),
      BannerType.demo => (
          AppColors.chipPeachBg,
          AppColors.warning,
          AppColors.chipPeachFg,
          Icons.flag_outlined,
        ),
    };

    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(customIcon ?? icon, size: 16, color: foreground),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                color: foreground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
