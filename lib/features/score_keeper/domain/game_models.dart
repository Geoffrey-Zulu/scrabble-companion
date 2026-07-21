/// In-memory / UI models for an active Scrabble score session.
class GamePlayer {
  const GamePlayer({
    required this.seatIndex,
    required this.name,
    this.dbId,
    this.score = 0,
  });

  final int? dbId;
  final int seatIndex;
  final String name;
  final int score;

  GamePlayer copyWith({int? dbId, String? name, int? score}) {
    return GamePlayer(
      seatIndex: seatIndex,
      name: name ?? this.name,
      dbId: dbId ?? this.dbId,
      score: score ?? this.score,
    );
  }
}

class GameTurn {
  const GameTurn({
    required this.playerSeat,
    required this.playerName,
    required this.round,
    required this.points,
    this.dbId,
    this.word,
  });

  final int? dbId;
  final int playerSeat;
  final String playerName;
  final int round;
  final int points;
  final String? word;
}

class ActiveGame {
  const ActiveGame({
    required this.id,
    required this.startedAt,
    required this.players,
    this.history = const [],
    this.finished = false,
    this.endedAt,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<GamePlayer> players;
  final List<GameTurn> history;
  final bool finished;

  int get round {
    if (players.isEmpty) {
      return 1;
    }
    return (history.length ~/ players.length) + 1;
  }

  int get leaderSeat {
    if (players.isEmpty) {
      return 0;
    }
    var best = players.first;
    for (final p in players.skip(1)) {
      if (p.score > best.score) {
        best = p;
      }
    }
    return best.seatIndex;
  }

  GamePlayer get winner {
    final seat = leaderSeat;
    return players.firstWhere((p) => p.seatIndex == seat);
  }

  ActiveGame copyWith({
    List<GamePlayer>? players,
    List<GameTurn>? history,
    bool? finished,
    DateTime? endedAt,
  }) {
    return ActiveGame(
      id: id,
      startedAt: startedAt,
      players: players ?? this.players,
      history: history ?? this.history,
      finished: finished ?? this.finished,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}

class GameStats {
  const GameStats({
    required this.highestTurn,
    required this.averageTurn,
    required this.totalRounds,
    required this.durationLabel,
  });

  final int highestTurn;
  final double averageTurn;
  final int totalRounds;
  final String durationLabel;

  static GameStats fromGame(ActiveGame game) {
    final turns = game.history;
    final highest = turns.isEmpty
        ? 0
        : turns.map((t) => t.points).reduce((a, b) => a > b ? a : b);
    final avg = turns.isEmpty
        ? 0.0
        : turns.map((t) => t.points).reduce((a, b) => a + b) / turns.length;
    final end = game.endedAt ?? DateTime.now();
    final minutes = (end.difference(game.startedAt).inSeconds / 60)
        .round()
        .clamp(1, 9999);
    final durationLabel = minutes >= 60
        ? '${minutes ~/ 60} hr ${minutes % 60} min'
        : '$minutes min';
    final rounds = game.players.isEmpty
        ? 0
        : ((turns.length + game.players.length - 1) ~/ game.players.length);
    return GameStats(
      highestTurn: highest,
      averageTurn: avg,
      totalRounds: rounds,
      durationLabel: durationLabel,
    );
  }
}
