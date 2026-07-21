import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class SettingsRows extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  TextColumn get textScale => text().withDefault(const Constant('medium'))();
  IntColumn get warnAtSeconds => integer().withDefault(const Constant(10))();
  TextColumn get soundMode => text().withDefault(const Constant('soundA'))();
  RealColumn get soundVolume => real().withDefault(const Constant(0.8))();
  BoolColumn get hapticsEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get dictionaryLocale =>
      text().withDefault(const Constant('northAmerican'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FavoriteWords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text()();
  TextColumn get lexicon => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class RecentLookups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get word => text()();
  BoolColumn get valid => boolean()();
  DateTimeColumn get lookedUpAt => dateTime().withDefault(currentDateAndTime)();
}

class Games extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  BoolColumn get finished => boolean().withDefault(const Constant(false))();
  IntColumn get durationMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get gameId => text().references(Games, #id)();
  TextColumn get name => text()();
  IntColumn get seatIndex => integer()();
  IntColumn get finalScore => integer().withDefault(const Constant(0))();
}

class Turns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get gameId => text().references(Games, #id)();
  IntColumn get playerId => integer().references(Players, #id)();
  IntColumn get round => integer()();
  IntColumn get points => integer()();
  TextColumn get word => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [SettingsRows, FavoriteWords, RecentLookups, Games, Players, Turns],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'scrabble_companion');
  }
}
