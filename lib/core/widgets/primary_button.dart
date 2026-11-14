import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../theme/app_tokens.dart';

/// Primary call-to-action used across Si Cehat.
///
/// Pill shaped, 48dp tall, flat — matching the Calm Sage button spec.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final Widget? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.height = AppSizes.buttonHeight,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || onPressed == null;
    final effectiveBg = backgroundColor ??
        (isOutlined ? AppColors.surface : AppColors.primary);
    final effectiveText = textColor ??
        (isOutlined ? AppColors.primary : AppColors.onPrimary);

    final child = _buildChild(effectiveText);

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: isLoading ? '$text, sedang diproses' : text,
      excludeSemantics: true,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: isOutlined
            ? OutlinedButton(
                onPressed: isDisabled ? null : onPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: effectiveText,
                  backgroundColor: effectiveBg,
                  side: BorderSide(
                    color: isDisabled ? AppColors.border : AppColors.primary,
                    width: 1,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                ),
                child: child,
              )
            : FilledButton(
                onPressed: isDisabled ? null : onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: effectiveBg,
                  foregroundColor: effectiveText,
                  disabledBackgroundColor: AppColors.primarySoft,
                  disabledForegroundColor: AppColors.textPlaceholder,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                ),
                child: child,
              ),
      ),
    );
  }

  Widget _buildChild(Color currentTextColor) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(currentTextColor),
        ),
      );
    }

    final textWidget = Text(
      text,
      textAlign: TextAlign.center,
      style: AppTypography.buttonLabel.copyWith(color: currentTextColor),
    );

    if (icon == null) return textWidget;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconTheme(
          data: IconThemeData(color: currentTextColor, size: 18),
          child: icon!,
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(child: textWidget),
      ],
    );
  }
}
