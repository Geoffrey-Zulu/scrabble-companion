import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/data/local/app_database.dart';
import 'package:scrabble_companion/data/repositories/game_repository.dart';

void main() {
  late AppDatabase db;
  late GameRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = GameRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('addTurn, editTurn, and undo keep player totals consistent', () async {
    var game = await repo.createGame(['Ada', 'Ben']);
    expect(game.players.map((p) => p.score), [0, 0]);

    game = await repo.addTurn(
      gameId: game.id,
      playerSeat: 0,
      points: 24,
      word: 'QUIZ',
    );
    expect(game.history, hasLength(1));
    expect(game.players[0].score, 24);
    expect(game.history.single.word, 'QUIZ');
    final turnId = game.history.single.dbId!;

    game = await repo.updateTurn(
      gameId: game.id,
      turnId: turnId,
      points: 30,
      word: 'QUIZZED',
    );
    expect(game.players[0].score, 30);
    expect(game.history.single.points, 30);
    expect(game.history.single.word, 'QUIZZED');

    game = await repo.addTurn(gameId: game.id, playerSeat: 1, points: 12);
    expect(game.players.map((p) => p.score), [30, 12]);
    expect(game.round, greaterThan(1));

    game = await repo.undoLastTurn(game.id);
    expect(game.players.map((p) => p.score), [30, 0]);
    expect(game.history, hasLength(1));
  });

  test('negative points subtract from player totals', () async {
    var game = await repo.createGame(['Ada', 'Ben']);
    game = await repo.addTurn(gameId: game.id, playerSeat: 0, points: 40);
    game = await repo.addTurn(gameId: game.id, playerSeat: 0, points: -12);
    expect(game.players[0].score, 28);
    expect(game.history.last.points, -12);

    final turnId = game.history.last.dbId!;
    game = await repo.updateTurn(gameId: game.id, turnId: turnId, points: -5);
    expect(game.players[0].score, 35);
    expect(game.history.last.points, -5);
  });

  test('endGame marks finished and appears in recent list', () async {
    var game = await repo.createGame(['Ada', 'Ben']);
    game = await repo.addTurn(gameId: game.id, playerSeat: 0, points: 40);
    game = await repo.endGame(game.id);

    expect(game.finished, isTrue);
    expect(await repo.loadActive(), isNull);

    final recent = await repo.recentFinished();
    expect(recent, hasLength(1));
    expect(recent.single.winner, 'Ada');
    expect(recent.single.score, 40);
  });
}
