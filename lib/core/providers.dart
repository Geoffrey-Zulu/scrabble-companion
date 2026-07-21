import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dictionary/lexicon.dart';
import '../data/dictionary/lexicon_loader.dart';
import '../data/local/app_database.dart';
import '../data/repositories/dictionary_repository.dart';
import '../data/repositories/settings_repository.dart';
import 'settings/settings_notifier.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

final lookupHistoryRepositoryProvider = Provider<LookupHistoryRepository>((
  ref,
) {
  return LookupHistoryRepository(ref.watch(appDatabaseProvider));
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(appDatabaseProvider));
});

final lexiconLoaderProvider = Provider<LexiconLoader>((ref) {
  return LexiconLoader();
});

final lexiconProvider = FutureProvider<Lexicon>((ref) async {
  final locale = ref.watch(settingsProvider.select((s) => s.dictionaryLocale));
  return ref.watch(lexiconLoaderProvider).load(locale);
});

/// Loads persisted settings once. Keep watched so the database stays warm.
final settingsBootstrapProvider = FutureProvider<void>((ref) async {
  final loaded = await ref.watch(settingsRepositoryProvider).load();
  ref.read(settingsProvider.notifier).hydrate(loaded);
});
