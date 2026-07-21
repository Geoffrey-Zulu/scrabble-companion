import 'package:flutter/animation.dart';

/// Motion tokens from the Claude Design prototype.
abstract final class AppMotion {
  static const Duration fadeIn = Duration(milliseconds: 280);
  static const Duration fadeUp = Duration(milliseconds: 280);
  static const Duration sheet = Duration(milliseconds: 300);
  static const Duration pop = Duration(milliseconds: 400);
  static const Duration tileIn = Duration(milliseconds: 600);
  static const Duration splashHold = Duration(milliseconds: 1150);
  static const Duration toggle = Duration(milliseconds: 200);
  static const Duration toast = Duration(milliseconds: 1600);
  static const Duration ringTick = Duration(seconds: 1);

  /// Matches CSS `cubic-bezier(.2, .8, .2, 1)`.
  static const Curve emphasized = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve standard = Curves.ease;
}
