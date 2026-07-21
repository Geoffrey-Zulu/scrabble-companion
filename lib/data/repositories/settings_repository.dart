import 'package:drift/drift.dart';

import '../../core/settings/app_settings.dart';
import '../local/app_database.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<AppSettings> load() async {
    final row = await (_db.select(
      _db.settingsRows,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (row == null) {
      const defaults = AppSettings();
      await save(defaults);
      return defaults;
    }
    return AppSettings(
      themeMode: AppThemeMode.values.byName(row.themeMode),
      textScale: TextScaleOption.values.byName(row.textScale),
      warnAtSeconds: row.warnAtSeconds,
      soundMode: TimerSoundMode.values.byName(row.soundMode),
      soundVolume: row.soundVolume,
      hapticsEnabled: row.hapticsEnabled,
      dictionaryLocale: DictionaryLocale.values.byName(row.dictionaryLocale),
    );
  }

  Future<void> save(AppSettings settings) async {
    await _db
        .into(_db.settingsRows)
        .insertOnConflictUpdate(
          SettingsRowsCompanion.insert(
            id: const Value(1),
            themeMode: Value(settings.themeMode.name),
            textScale: Value(settings.textScale.name),
            warnAtSeconds: Value(settings.warnAtSeconds),
            soundMode: Value(settings.soundMode.name),
            soundVolume: Value(settings.soundVolume),
            hapticsEnabled: Value(settings.hapticsEnabled),
            dictionaryLocale: Value(settings.dictionaryLocale.name),
          ),
        );
  }
}
