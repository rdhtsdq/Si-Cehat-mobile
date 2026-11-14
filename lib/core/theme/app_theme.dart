import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_tokens.dart';

/// Global "Calm Sage" theme.
///
/// Component themes encode the visual rules once: pill buttons, white inputs
/// with a thin mint border, flat cards, 24px bottom sheets and a soft slider.
class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.chipTealFg,
      onSecondary: AppColors.onPrimary,
      secondaryContainer: AppColors.primarySoft2,
      onSecondaryContainer: AppColors.chipTealFg,
      tertiary: AppColors.chipPeachFg,
      onTertiary: AppColors.onPrimary,
      error: AppColors.dangerText,
      onError: AppColors.onPrimary,
      errorContainer: AppColors.dangerBg,
      onErrorContainer: AppColors.dangerText,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      onSurfaceVariant: AppColors.textMuted,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      shadow: Color(0x261D2B29),
      scrim: Color(0x731D2B29),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      disabledColor: AppColors.textPlaceholder,
      hintColor: AppColors.textPlaceholder,
      fontFamily: 'Plus Jakarta Sans',
      splashColor: AppColors.primarySoft,
      highlightColor: AppColors.primarySoft.withValues(alpha: 0.6),
      textTheme: AppTypography.textTheme,
      iconTheme: const IconThemeData(color: AppColors.text, size: 20),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primarySoft2,
        selectionHandleColor: AppColors.primary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 56,
        iconTheme: const IconThemeData(color: AppColors.onPrimary, size: 20),
        titleTextStyle: AppTypography.title.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primarySoft,
          disabledForegroundColor: AppColors.textPlaceholder,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.buttonLabel,
          elevation: 0,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primarySoft,
          disabledForegroundColor: AppColors.textPlaceholder,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.buttonLabel,
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          side: const BorderSide(color: AppColors.border, width: 1),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.buttonLabel.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.title.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 14,
        ),
        hintStyle: AppTypography.body.copyWith(
          color: AppColors.textPlaceholder,
          fontSize: 13,
        ),
        labelStyle: AppTypography.formLabel,
        floatingLabelStyle: AppTypography.formLabel.copyWith(
          color: AppColors.primary,
        ),
        errorStyle: AppTypography.caption.copyWith(color: AppColors.dangerText),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.chevron,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.dangerText, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.dangerText, width: 1.5),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primarySoft2,
        disabledColor: AppColors.chipNeutralBg,
        surfaceTintColor: Colors.transparent,
        side: const BorderSide(color: AppColors.border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: AppTypography.title.copyWith(color: AppColors.text),
        secondaryLabelStyle: AppTypography.title.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
        showCheckmark: false,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardLarge),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xl,
        ),
        titleTextStyle: AppTypography.h2,
        contentTextStyle: AppTypography.body,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Color(0x731D2B29),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        dragHandleColor: AppColors.border,
        dragHandleSize: Size(36, 4),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.text,
        contentTextStyle: AppTypography.body.copyWith(
          color: AppColors.onPrimary,
          fontSize: 13,
        ),
        elevation: 0,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.input,
        ),
      ),

      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: AppColors.text,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.caption.copyWith(color: AppColors.onPrimary),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearMinHeight: 6,
        linearTrackColor: AppColors.primarySoft,
        circularTrackColor: AppColors.primarySoft,
      ),

      sliderTheme: SliderThemeData(
        trackHeight: 6,
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primarySoft,
        thumbColor: AppColors.surface,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
        thumbShape: const _RingThumbShape(
          radius: 11,
          ringColor: AppColors.primary,
          fillColor: AppColors.surface,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        tickMarkShape: SliderTickMarkShape.noTickMark,
        showValueIndicator: ShowValueIndicator.never,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: AppColors.primary,
        textColor: AppColors.text,
        titleTextStyle: AppTypography.title.copyWith(
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: AppTypography.caption,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        minVerticalPadding: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: CircleBorder(),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary,
        elevation: 0,
        height: AppSizes.navBarHeight,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTypography.micro.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.onPrimary
                : AppColors.textMuted,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? AppColors.onPrimary
                : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// Slider thumb: white fill with a 3px primary ring, per the picker spec.
class _RingThumbShape extends SliderComponentShape {
  final double radius;
  final Color ringColor;
  final Color fillColor;

  const _RingThumbShape({
    required this.radius,
    required this.ringColor,
    required this.fillColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius + 2);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = ringColor,
    );
    canvas.drawCircle(
      center,
      radius - 3,
      Paint()..color = fillColor,
    );
  }
}
