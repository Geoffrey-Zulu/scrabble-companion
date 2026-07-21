/// User-facing preferences. Persisted via Drift ([SettingsRepository]).
enum AppThemeMode { light, dark, system }

enum TextScaleOption {
  small(0.9, 'Small'),
  medium(1, 'Medium'),
  large(1.15, 'Large');

  const TextScaleOption(this.factor, this.label);

  final double factor;
  final String label;
}

enum TimerSoundMode { off, soundA, soundB }

enum DictionaryLocale { northAmerican, british }

class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.textScale = TextScaleOption.medium,
    this.warnAtSeconds = 10,
    this.soundMode = TimerSoundMode.soundA,
    this.soundVolume = 1,
    this.hapticsEnabled = true,
    this.dictionaryLocale = DictionaryLocale.northAmerican,
  });

  final AppThemeMode themeMode;
  final TextScaleOption textScale;
  final int warnAtSeconds;
  final TimerSoundMode soundMode;
  final double soundVolume;
  final bool hapticsEnabled;
  final DictionaryLocale dictionaryLocale;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    TextScaleOption? textScale,
    int? warnAtSeconds,
    TimerSoundMode? soundMode,
    double? soundVolume,
    bool? hapticsEnabled,
    DictionaryLocale? dictionaryLocale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      textScale: textScale ?? this.textScale,
      warnAtSeconds: warnAtSeconds ?? this.warnAtSeconds,
      soundMode: soundMode ?? this.soundMode,
      soundVolume: soundVolume ?? this.soundVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      dictionaryLocale: dictionaryLocale ?? this.dictionaryLocale,
    );
  }
}
