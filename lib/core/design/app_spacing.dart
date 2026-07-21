/// Spacing scale from the Claude Design prototype.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 18;
  static const double card = 22;
  static const double pageX = 26;
  static const double section = 34;
  static const double navHeight = 84;
  static const double minTouchTarget = 44;

  /// Bottom inset so the last content sits just above the tab bar - not a
  /// large empty scroll region.
  static const double scrollBottomClearance = navHeight + 12;
}
