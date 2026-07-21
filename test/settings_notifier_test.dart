import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/core/design/app_colors.dart';
import 'package:scrabble_companion/core/settings/app_settings.dart';
import 'package:scrabble_companion/core/settings/settings_notifier.dart';

void main() {
  group('AppColors', () {
    test('light and dark expose distinct backgrounds', () {
      expect(AppColors.light.bg, isNot(AppColors.dark.bg));
      expect(AppColors.light.accent, const Color(0xFFD97757));
      expect(AppColors.dark.accent, const Color(0xFFE28A6C));
    });
  });

  group('SettingsNotifier', () {
    test('updates theme, text scale, and reset', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier)
        ..setThemeMode(AppThemeMode.dark);
      expect(container.read(settingsProvider).themeMode, AppThemeMode.dark);

      notifier.setTextScale(TextScaleOption.large);
      expect(container.read(settingsProvider).textScale, TextScaleOption.large);

      notifier.resetAll();
      expect(container.read(settingsProvider).themeMode, AppThemeMode.system);
      expect(
        container.read(settingsProvider).textScale,
        TextScaleOption.medium,
      );
    });
  });
}
