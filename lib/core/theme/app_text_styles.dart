import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// "Calm Sage" type scale.
///
/// Plus Jakarta Sans keeps the product warm and humanist; the scale is compact
/// on purpose (11–24sp) so dense health data still fits on a 360px screen.
class AppTypography {
  const AppTypography._();

  static TextStyle _sans({
    required double size,
    required double height,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.text,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      height: height / size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  // ---------------------------------------------------------------------------
  // Spec scale
  // ---------------------------------------------------------------------------
  static TextStyle get display =>
      _sans(size: 24, height: 30, weight: FontWeight.w700);
  static TextStyle get hero =>
      _sans(size: 22, height: 28, weight: FontWeight.w700);
  static TextStyle get h2 =>
      _sans(size: 16, height: 22, weight: FontWeight.w700);
  static TextStyle get title =>
      _sans(size: 13, height: 18, weight: FontWeight.w600);
  static TextStyle get body =>
      _sans(size: 12, height: 18, weight: FontWeight.w400);
  static TextStyle get caption =>
      _sans(size: 11, height: 15, weight: FontWeight.w400,
          color: AppColors.textMuted);
  static TextStyle get micro =>
      _sans(size: 10, height: 14, weight: FontWeight.w500,
          color: AppColors.textMuted);
  static TextStyle get formLabel =>
      _sans(size: 12, height: 16, weight: FontWeight.w600);
  static TextStyle get buttonLabel =>
      _sans(size: 13, height: 18, weight: FontWeight.w700,
          color: AppColors.onPrimary);
  static TextStyle get overline => _sans(
        size: 10,
        height: 14,
        weight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 0.6,
      );

  // ---------------------------------------------------------------------------
  // Backwards-compatible names used by pre-redesign screens.
  // ---------------------------------------------------------------------------
  static TextStyle get headingSplash => _sans(
        size: 32,
        height: 38,
        weight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: -0.6,
      );

  static TextStyle get headingScreen => display;

  static TextStyle get headingLogin => display;

  static TextStyle get subHeading => h2;

  static TextStyle get titleCard => title;

  static TextStyle get bodyRegular => body;

  static TextStyle get bodySecondary =>
      body.copyWith(color: AppColors.textMuted);

  static TextStyle get bodyStrong => title.copyWith(fontWeight: FontWeight.w600);

  static TextStyle get labelInput => formLabel;

  static TextStyle get textInput =>
      _sans(size: 13, height: 18, weight: FontWeight.w500);

  static TextStyle get buttonText => buttonLabel;

  static TextStyle get navLabel => micro;

  static TextStyle get badgeText => micro.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      );

  /// Default styles for widgets that do not set a style explicitly.
  static TextTheme get textTheme => TextTheme(
        displaySmall: headingSplash,
        headlineMedium: display,
        headlineSmall: subHeading,
        titleLarge: _sans(size: 18, height: 24, weight: FontWeight.w700),
        titleMedium: title,
        titleSmall: _sans(size: 13, height: 18, weight: FontWeight.w600),
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: caption,
        labelLarge: buttonLabel.copyWith(color: AppColors.text),
        labelMedium: formLabel,
        labelSmall: micro.copyWith(fontWeight: FontWeight.w600),
      );
}
