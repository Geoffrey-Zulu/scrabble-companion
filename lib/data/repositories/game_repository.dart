import 'package:drift/drift.dart';

import '../../features/home/presentation/recent_games_list.dart';
import '../../features/score_keeper/domain/game_models.dart';
import '../local/app_database.dart';

class GameRepository {
  GameRepository(this._db);

  final AppDatabase _db;

  static const recentCap = 12;

  Future<ActiveGame?> loadActive() async {
    final row = await (_db.select(_db.games)
          ..where((g) => g.finished.equals(false))
          ..orderBy([(g) => OrderingTerm.desc(g.startedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _hydrate(row);
  }

  Future<ActiveGame> createGame(List<String> names) async {
    final id = 'g-${DateTime.now().microsecondsSinceEpoch}';
    final started = DateTime.now();
    await _db.transaction(() async {
      await _db
          .into(_db.games)
          .insert(
            GamesCompanion.insert(id: id, startedAt: started),
          );
      for (var i = 0; i < names.length; i++) {
        await _db
            .into(_db.players)
            .insert(
              PlayersCompanion.insert(
                gameId: id,
                name: names[i],
                seatIndex: i,
              ),
            );
      }
    });
    final loaded = await loadById(id);
    return loaded!;
  }

  Future<ActiveGame?> loadById(String id) async {
    final row = await (_db.select(
      _db.games,
    )..where((g) => g.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _hydrate(row);
  }

  Future<ActiveGame> addTurn({
    required String gameId,
    required int playerSeat,
    required int points,
    String? word,
  }) async {
    final game = await loadById(gameId);
    if (game == null || game.finished) {
      throw StateError('No active game');
    }
    final player = game.players.firstWhere((p) => p.seatIndex == playerSeat);
    final playerId = player.dbId;
    if (playerId == null) {
      throw StateError('Player missing db id');
    }
    final round = game.round;
    await _db.transaction(() async {
      await _db
          .into(_db.turns)
          .insert(
            TurnsCompanion.insert(
              gameId: gameId,
              playerId: playerId,
              round: round,
              points: points,
              word: Value(word),
            ),
          );
      await (_db.update(_db.players)..where((p) => p.id.equals(playerId)))
          .write(PlayersCompanion(finalScore: Value(player.score + points)));
    });
    return (await loadById(gameId))!;
  }

  Future<ActiveGame> undoLastTurn(String gameId) async {
    final game = await loadById(gameId);
    if (game == null || game.history.isEmpty) {
      throw StateError('Nothing to undo');
    }
    final last = game.history.last;
    final player = game.players.firstWhere((p) => p.seatIndex == last.playerSeat);
    final playerId = player.dbId!;
    final turnId = last.dbId!;
    await _db.transaction(() async {
      await (_db.delete(_db.turns)..where((t) => t.id.equals(turnId))).go();
      await (_db.update(_db.players)..where((p) => p.id.equals(playerId))).write(
        PlayersCompanion(
          finalScore: Value((player.score - last.points).clamp(0, 999999)),
        ),
      );
    });
    return (await loadById(gameId))!;
  }

  Future<ActiveGame> updateTurn({
    required String gameId,
    required int turnId,
    required int points,
    String? word,
  }) async {
    final game = await loadById(gameId);
    if (game == null || game.finished) {
      throw StateError('No active game');
    }
    final turn = game.history.firstWhere(
      (t) => t.dbId == turnId,
      orElse: () => throw StateError('Turn not found'),
    );
    final player = game.players.firstWhere((p) => p.seatIndex == turn.playerSeat);
    final playerId = player.dbId!;
    final nextPoints = points.clamp(0, 999);
    final delta = nextPoints - turn.points;
    final cleaned = word?.trim().toUpperCase();
    await _db.transaction(() async {
      await (_db.update(_db.turns)..where((t) => t.id.equals(turnId))).write(
        TurnsCompanion(
          points: Value(nextPoints),
          word: Value((cleaned == null || cleaned.isEmpty) ? null : cleaned),
        ),
      );
      await (_db.update(_db.players)..where((p) => p.id.equals(playerId))).write(
        PlayersCompanion(
          finalScore: Value((player.score + delta).clamp(0, 999999)),
        ),
      );
    });
    return (await loadById(gameId))!;
  }

  Future<ActiveGame> endGame(String gameId) async {
    final game = await loadById(gameId);
    if (game == null) {
      throw StateError('Missing game');
    }
    final ended = DateTime.now();
    final durationMs = ended.difference(game.startedAt).inMilliseconds;
    await (_db.update(_db.games)..where((g) => g.id.equals(gameId))).write(
      GamesCompanion(
        finished: const Value(true),
        endedAt: Value(ended),
        durationMs: Value(durationMs),
      ),
    );
    return (await loadById(gameId))!;
  }

  Future<List<RecentGameSummary>> recentFinished() async {
    final rows =
        await (_db.select(_db.games)
              ..where((g) => g.finished.equals(true))
              ..orderBy([(g) => OrderingTerm.desc(g.endedAt)])
              ..limit(recentCap))
            .get();
    final out = <RecentGameSummary>[];
    for (final row in rows) {
      final players = await (_db.select(
        _db.players,
      )..where((p) => p.gameId.equals(row.id))).get();
      if (players.isEmpty) {
        continue;
      }
      players.sort((a, b) => b.finalScore.compareTo(a.finalScore));
      final winner = players.first;
      final ended = row.endedAt ?? row.startedAt;
      final minutes = ((row.durationMs ?? 60000) / 60000).round().clamp(1, 9999);
      final durationLabel = minutes >= 60
          ? '${minutes ~/ 60} hr ${minutes % 60} min'
          : '$minutes min';
      out.add(
        RecentGameSummary(
          id: row.id,
          winner: winner.name,
          date: _shortDate(ended),
          durationLabel: durationLabel,
          score: winner.finalScore,
        ),
      );
    }
    return out;
  }

  Future<void> deleteGame(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.turns)..where((t) => t.gameId.equals(id))).go();
      await (_db.delete(_db.players)..where((p) => p.gameId.equals(id))).go();
      await (_db.delete(_db.games)..where((g) => g.id.equals(id))).go();
    });
  }

  Future<ActiveGame> _hydrate(Game row) async {
    final players =
        await (_db.select(_db.players)
              ..where((p) => p.gameId.equals(row.id))
              ..orderBy([(p) => OrderingTerm.asc(p.seatIndex)]))
            .get();
    final turns =
        await (_db.select(_db.turns)
              ..where((t) => t.gameId.equals(row.id))
              ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
            .get();
    final byId = {for (final p in players) p.id: p};
    return ActiveGame(
      id: row.id,
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      finished: row.finished,
      players: [
        for (final p in players)
          GamePlayer(
            dbId: p.id,
            seatIndex: p.seatIndex,
            name: p.name,
            score: p.finalScore,
          ),
      ],
      history: [
        for (final t in turns)
          GameTurn(
            dbId: t.id,
            playerSeat: byId[t.playerId]?.seatIndex ?? 0,
            playerName: byId[t.playerId]?.name ?? 'Player',
            round: t.round,
            points: t.points,
            word: t.word,
          ),
      ],
    );
  }

  static String _shortDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}
