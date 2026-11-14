import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/calm_widgets.dart';

/// Severity of the risk card. `unknown` is the honest default when no
/// screening result exists — never fall back to "low".
enum RiskTone { low, medium, high, unknown }

/// Diabetes Risk Meter card.
///
/// White card on cream, status communicated with icon + text + colour so the
/// meaning never depends on colour alone.
class RiskMeterCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final RiskTone tone;
  final String ctaLabel;
  final VoidCallback onTap;

  const RiskMeterCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tone,
    required this.onTap,
    this.ctaLabel = 'Lakukan skrining',
  });

  RiskLevel get _level => switch (tone) {
    RiskTone.low => RiskLevel.low,
    RiskTone.medium => RiskLevel.medium,
    RiskTone.high => RiskLevel.high,
    RiskTone.unknown => RiskLevel.unknown,
  };

  @override
  Widget build(BuildContext context) {
    final palette = RiskPalette.of(_level);

    return Semantics(
      button: true,
      label: '$title. $subtitle. $ctaLabel',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DIABETES RISK METER', style: AppTypography.overline),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: palette.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: palette.border),
                      ),
                      child: Icon(
                        RiskPalette.iconOf(_level),
                        size: 20,
                        color: palette.foreground,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.hero.copyWith(
                          color: palette.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        ctaLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
