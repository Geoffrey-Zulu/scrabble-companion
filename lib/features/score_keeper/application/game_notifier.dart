import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../data/repositories/game_repository.dart';
import '../../home/presentation/recent_games_list.dart';
import '../domain/game_models.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository(ref.watch(appDatabaseProvider));
});

final recentGamesProvider = FutureProvider<List<RecentGameSummary>>((
  ref,
) async {
  return ref.watch(gameRepositoryProvider).recentFinished();
});

final gameProvider = AsyncNotifierProvider<GameNotifier, ActiveGame?>(
  GameNotifier.new,
);

class GameNotifier extends AsyncNotifier<ActiveGame?> {
  GameRepository get _repo => ref.read(gameRepositoryProvider);

  @override
  Future<ActiveGame?> build() {
    return _repo.loadActive();
  }

  Future<ActiveGame> startGame(List<String> rawNames) async {
    final names = <String>[];
    for (var i = 0; i < rawNames.length; i++) {
      final trimmed = rawNames[i].trim();
      names.add(trimmed.isEmpty ? 'Player ${i + 1}' : trimmed);
    }
    if (names.length < 2 || names.length > 6) {
      throw ArgumentError('Need 2–6 players');
    }
    // End any unfinished game before starting a new one.
    final existing = state.value;
    if (existing != null && !existing.finished) {
      await _repo.endGame(existing.id);
    }
    final game = await _repo.createGame(names);
    state = AsyncData(game);
    ref.invalidate(recentGamesProvider);
    return game;
  }

  Future<void> addScore({
    required int playerSeat,
    required int points,
    String? word,
  }) async {
    final current = state.value;
    if (current == null || current.finished) {
      return;
    }
    final cleaned = word?.trim().toUpperCase();
    final game = await _repo.addTurn(
      gameId: current.id,
      playerSeat: playerSeat,
      points: points.clamp(0, 999),
      word: (cleaned == null || cleaned.isEmpty) ? null : cleaned,
    );
    state = AsyncData(game);
  }

  Future<void> undo() async {
    final current = state.value;
    if (current == null || current.history.isEmpty) {
      return;
    }
    final game = await _repo.undoLastTurn(current.id);
    state = AsyncData(game);
  }

  Future<void> editTurn({
    required int turnId,
    required int points,
    String? word,
  }) async {
    final current = state.value;
    if (current == null || current.finished) {
      return;
    }
    final cleaned = word?.trim().toUpperCase();
    final game = await _repo.updateTurn(
      gameId: current.id,
      turnId: turnId,
      points: points.clamp(0, 999),
      word: (cleaned == null || cleaned.isEmpty) ? null : cleaned,
    );
    state = AsyncData(game);
  }

  Future<ActiveGame?> endGame() async {
    final current = state.value;
    if (current == null) {
      return null;
    }
    final game = await _repo.endGame(current.id);
    // Keep the finished game in memory so ScoreScreen doesn't race-redirect
    // home while we navigate to the winner page.
    state = AsyncData(game);
    ref.invalidate(recentGamesProvider);
    return game;
  }

  Future<void> deleteRecent(String id) async {
    await _repo.deleteGame(id);
    ref.invalidate(recentGamesProvider);
    if (state.value?.id == id) {
      state = const AsyncData(null);
    }
  }

  Future<void> clearActiveFromMemory() async {
    state = const AsyncData(null);
  }
}
