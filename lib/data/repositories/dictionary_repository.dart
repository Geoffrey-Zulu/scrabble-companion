import 'package:drift/drift.dart';

import '../local/app_database.dart';

class LookupHistoryRepository {
  LookupHistoryRepository(this._db);

  final AppDatabase _db;
  static const _recentLimit = 6;

  Future<List<RecentLookup>> recent() {
    return (_db.select(_db.recentLookups)
          ..orderBy([(t) => OrderingTerm.desc(t.lookedUpAt)])
          ..limit(_recentLimit))
        .get();
  }

  Future<void> record({required String word, required bool valid}) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.recentLookups,
      )..where((t) => t.word.equals(word))).go();
      await _db
          .into(_db.recentLookups)
          .insert(RecentLookupsCompanion.insert(word: word, valid: valid));
      final all = await (_db.select(
        _db.recentLookups,
      )..orderBy([(t) => OrderingTerm.desc(t.lookedUpAt)])).get();
      if (all.length > _recentLimit) {
        final drop = all.skip(_recentLimit).map((e) => e.id);
        await (_db.delete(
          _db.recentLookups,
        )..where((t) => t.id.isIn(drop))).go();
      }
    });
  }

  Future<void> clear() => _db.delete(_db.recentLookups).go();
}

class FavoritesRepository {
  FavoritesRepository(this._db);

  final AppDatabase _db;

  Future<Set<String>> allWords() async {
    final rows = await _db.select(_db.favoriteWords).get();
    return rows.map((r) => r.word).toSet();
  }

  Future<bool> isFavorite(String word) async {
    final row = await (_db.select(
      _db.favoriteWords,
    )..where((t) => t.word.equals(word))).getSingleOrNull();
    return row != null;
  }

  Future<void> toggle({required String word, required String lexicon}) async {
    final existing = await (_db.select(
      _db.favoriteWords,
    )..where((t) => t.word.equals(word))).getSingleOrNull();
    if (existing != null) {
      await (_db.delete(
        _db.favoriteWords,
      )..where((t) => t.id.equals(existing.id))).go();
    } else {
      await _db
          .into(_db.favoriteWords)
          .insert(FavoriteWordsCompanion.insert(word: word, lexicon: lexicon));
    }
  }
}
