import 'package:flutter/material.dart';

/// "Calm Sage" color tokens.
///
/// Single source of truth for every color used by the app. Screens must never
/// declare raw hex values; they consume these tokens (or the semantic aliases
/// kept for backwards compatibility with earlier screens).
class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------------------
  // Core palette
  // ---------------------------------------------------------------------------
  static const Color primary = Color(0xFF4A6E54);
  static const Color primarySoft = Color(0xFFEAF4F0);
  static const Color primarySoft2 = Color(0xFFDFF0EA);
  static const Color border = Color(0xFFD9E7E2);
  static const Color divider = Color(0xFFE8EFEB);
  static const Color bg = Color(0xFFFFFCF6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------
  static const Color text = Color(0xFF1D2B29);
  static const Color textMuted = Color(0xFF727A77);
  static const Color textPlaceholder = Color(0xFF8A8F93);
  static const Color headerSubtitle = Color(0xFFE3F0E6);
  static const Color chevron = Color(0xFF7F968D);

  // ---------------------------------------------------------------------------
  // Semantic / accent
  // ---------------------------------------------------------------------------
  static const Color dangerBg = Color(0xFFFADDDD);
  static const Color dangerText = Color(0xFFC72928);
  static const Color warning = Color(0xFFF5C16C);
  static const Color warningBg = Color(0xFFFFF8EC);
  static const Color success = Color(0xFF6FCB8A);
  static const Color due = Color(0xFF8E97B7);

  // ---------------------------------------------------------------------------
  // Risk levels (pastel bg + deeper fg + border)
  // ---------------------------------------------------------------------------
  static const Color riskLowBg = primarySoft;
  static const Color riskLowFg = primary;
  static const Color riskLowBorder = border;

  static const Color riskMediumBg = warningBg;
  static const Color riskMediumFg = Color(0xFFB45309);
  static const Color riskMediumBorder = warning;

  static const Color riskHighBg = dangerBg;
  static const Color riskHighFg = dangerText;
  static const Color riskHighBorder = Color(0xFFF3B9B9);

  // ---------------------------------------------------------------------------
  // Icon chip pastel pairs
  // ---------------------------------------------------------------------------
  static const Color chipNeutralBg = Color(0xFFF2F4F2);
  static const Color chipNeutralFg = Color(0xFF8A8F93);
  static const Color chipTealBg = primarySoft2;
  static const Color chipTealFg = Color(0xFF16685C);
  static const Color chipRoseBg = Color(0xFFFFE2E2);
  static const Color chipRoseFg = Color(0xFFDB2777);
  static const Color chipPeachBg = Color(0xFFFFF1E8);
  static const Color chipPeachFg = Color(0xFFB45309);

  // ---------------------------------------------------------------------------
  // Backwards-compatible aliases used by screens written before the redesign.
  // Prefer the role-named tokens above for new code.
  // ---------------------------------------------------------------------------
  static const Color background = bg;
  static const Color scaffoldBackground = bg;
  static const Color fieldBackground = surface;
  static const Color cardBackground = surface;
  static const Color greyCard = chipNeutralBg;

  static const Color primaryGreen = primary;
  static const Color primaryGreenDark = primary;
  static const Color lightGreen = primarySoft2;
  static const Color paleGreenBg = primarySoft;
  static const Color veryLightGreen = primarySoft;

  static const Color accentYellow = warning;
  static const Color accentBlue = chipTealFg;
  static const Color accentOrange = chipPeachFg;
  static const Color accentRed = dangerText;

  static const Color textDark = text;
  static const Color textSecondary = textMuted;
  static const Color textMutedLegacy = textPlaceholder;

  static const Color warningText = riskMediumFg;

  static const Color textOnPrimary = onPrimary;
  static const Color action = primary;
  static const Color successBg = primarySoft;
  static const Color danger = dangerText;
  static const Color info = chipTealFg;
  static const Color infoBg = primarySoft2;
  static const Color sunBg = warningBg;
  static const Color surfaceMuted = chipNeutralBg;
  static const Color focus = primary;
}
