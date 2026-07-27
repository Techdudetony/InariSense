/// Spacing scale matching docs/07-design-system.md (4px base unit).
library;

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Default card padding per the design system.
  static const double cardPadding = lg;

  /// Default gap between distinct sections on a screen.
  static const double sectionGap = xl;
}
