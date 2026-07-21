import 'package:flutter/painting.dart';

/// Corner radii from the Claude Design prototype.
abstract final class AppRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 18;
  static const double card = 20;
  static const double result = 22;
  static const double pill = 24;
  static const double cta = 28;
  static const double sheet = 26;
  static const double timerPrimary = 46;
  static const double timerSecondary = 32;

  static const BorderRadius cardBorder = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius sheetBorder = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
  static const BorderRadius pillBorder = BorderRadius.all(
    Radius.circular(pill),
  );
}
