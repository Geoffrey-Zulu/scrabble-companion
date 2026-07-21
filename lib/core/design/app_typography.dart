import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography roles aligned with the design handoff.
///
/// Uses the platform text theme (SF Pro on Apple, system sans elsewhere)
/// rather than a default web stack like Inter/Roboto.
abstract final class AppTypography {
  static TextTheme textTheme(AppColors colors) {
    final base = Typography.material2021(
      platform: TargetPlatform.iOS,
    ).black.apply(bodyColor: colors.ink, displayColor: colors.ink);

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 74,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.04 * 74,
        height: 1,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: 46,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.03 * 46,
        height: 1,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.02 * 40,
        height: 1.1,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.02 * 34,
        height: 1.1,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.02 * 28,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01 * 22,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.02 * 13,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 1.55,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: colors.muted,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.08 * 12,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
