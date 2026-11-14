import 'package:flutter/material.dart';

/// Spacing scale in logical pixels (4px base).
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  /// Horizontal page gutter used by every full screen.
  static const double pageGutter = 16;

  /// Vertical padding above the first block of a screen.
  static const double pageTop = 16;

  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: pageGutter,
    vertical: pageTop,
  );
}

/// Corner radii from the Calm Sage system.
class AppRadius {
  const AppRadius._();

  static const double xs = 10;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 28;
  static const double pill = 999;

  static const BorderRadius button = BorderRadius.all(
    Radius.circular(pill),
  );
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius cardLarge = BorderRadius.all(
    Radius.circular(xl),
  );
  static const BorderRadius header = BorderRadius.vertical(
    bottom: Radius.circular(xxl),
  );
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

/// Fixed component sizes that must stay consistent for touch ergonomics.
class AppSizes {
  const AppSizes._();

  static const double minTouchTarget = 44;
  static const double buttonHeight = 48;
  static const double fieldHeight = 48;
  static const double navBarHeight = 62;
  static const double avatarSmall = 36;
  static const double avatarHeader = 44;
  static const double iconTile = 48;
}

/// Flat by default; only floating chrome (FAB/nav) gets a soft shadow.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> card = [];

  static const List<BoxShadow> float = [
    BoxShadow(
      color: Color(0x261D2B29),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> raised = float;
}
