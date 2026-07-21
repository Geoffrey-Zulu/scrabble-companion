import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  /// Replace state after loading from Drift (does not re-persist).
  // ignore: use_setters_to_change_properties
  void hydrate(AppSettings settings) {
    state = settings;
  }

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setTextScale(TextScaleOption scale) {
    state = state.copyWith(textScale: scale);
  }

  void setWarnAtSeconds(int seconds) {
    state = state.copyWith(warnAtSeconds: seconds);
  }

  void setSoundMode(TimerSoundMode mode) {
    state = state.copyWith(soundMode: mode);
  }

  void setSoundVolume(double volume) {
    state = state.copyWith(soundVolume: volume.clamp(0, 1));
  }

  void setHapticsEnabled({required bool enabled}) {
    state = state.copyWith(hapticsEnabled: enabled);
  }

  void setDictionaryLocale(DictionaryLocale locale) {
    state = state.copyWith(dictionaryLocale: locale);
  }

  void resetAll() {
    state = const AppSettings();
  }
}
