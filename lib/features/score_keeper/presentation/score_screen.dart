import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/widgets/sc_buttons.dart';
import '../application/game_notifier.dart';
import '../domain/game_models.dart';
import 'add_score_sheet.dart';

class ScoreScreen extends ConsumerWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final asyncGame = ref.watch(gameProvider);

    return asyncGame.when(
      loading: () => Scaffold(
        backgroundColor: colors.bg,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: colors.bg,
        body: Center(child: Text('Could not load game.\n$error')),
      ),
      data: (game) {
        if (game == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/home');
            }
          });
          return Scaffold(backgroundColor: colors.bg);
        }
        // Finished games are handed off to /game/winner — hold a quiet frame.
        if (game.finished) {
          return Scaffold(backgroundColor: colors.bg);
        }
        return _ScoreBody(game: game);
      },
    );
  }
}

class _ScoreBody extends ConsumerWidget {
  const _ScoreBody({required this.game});

  final ActiveGame game;

  Future<void> _addFor(BuildContext context, WidgetRef ref, GamePlayer p) async {
    final result = await showAddScoreSheet(
      context: context,
      player: p,
      round: game.round,
    );
    if (result == null) {
      return;
    }
    await ref
        .read(gameProvider.notifier)
        .addScore(
          playerSeat: p.seatIndex,
          points: result.points,
          word: result.word,
        );
  }

  Future<void> _editTurn(
    BuildContext context,
    WidgetRef ref,
    GameTurn turn,
  ) async {
    final player = game.players.firstWhere((p) => p.seatIndex == turn.playerSeat);
    final result = await showAddScoreSheet(
      context: context,
      player: player,
      round: turn.round,
      initialPoints: turn.points,
      initialWord: turn.word,
      submitLabel: 'Save',
      titleOverride: 'Edit ${turn.playerName}',
    );
    if (result == null || turn.dbId == null) {
      return;
    }
    await ref
        .read(gameProvider.notifier)
        .editTurn(
          turnId: turn.dbId!,
          points: result.points,
          word: result.word,
        );
  }

  Future<void> _end(BuildContext context, WidgetRef ref) async {
    await ref.read(hapticsServiceProvider).medium();
    final finished = await ref.read(gameProvider.notifier).endGame();
    if (finished != null && context.mounted) {
      context.go('/game/winner', extra: finished);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final columns = game.players.length <= 2
        ? 2
        : (game.players.length <= 4 ? 2 : 3);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      ref.read(hapticsServiceProvider).selection();
                      context.go('/home');
                    },
                    child: const Text('Home'),
                  ),
                  Expanded(
                    child: Text(
                      'Round ${game.round}',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: game.history.isEmpty
                        ? null
                        : () {
                            ref.read(hapticsServiceProvider).selection();
                            ref.read(gameProvider.notifier).undo();
                          },
                    child: const Text('Undo'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: game.players.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: columns == 3 ? 0.85 : 1.05,
                    ),
                    itemBuilder: (context, index) {
                      final player = game.players[index];
                      final isLeader =
                          player.seatIndex == game.leaderSeat &&
                          game.players.any((p) => p.score > 0);
                      return _PlayerTile(
                        player: player,
                        isLeader: isLeader,
                        onAdd: () => _addFor(context, ref, player),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'ROUND HISTORY',
                    style: textTheme.labelMedium?.copyWith(color: colors.faint),
                  ),
                  if (game.history.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'Tap a turn to edit',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.faint,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (game.history.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Tap Add on a player to log a turn.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.muted,
                        ),
                      ),
                    )
                  else
                    for (final turn in game.history.reversed)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _editTurn(context, ref, turn),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 4,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'R${turn.round}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.faint,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    turn.word == null || turn.word!.isEmpty
                                        ? turn.playerName
                                        : '${turn.playerName} · ${turn.word}',
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                                Text(
                                  '+${turn.points}',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ScSecondaryButton(
                label: 'End Game',
                expanded: true,
                onPressed: () => _end(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.player,
    required this.isLeader,
    required this.onAdd,
  });

  final GamePlayer player;
  final bool isLeader;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: isLeader ? colors.accent : colors.line,
          width: isLeader ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall,
                  ),
                ),
                if (isLeader)
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 16,
                    color: colors.accent,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              '${player.score}',
              style: textTheme.displaySmall?.copyWith(
                fontSize: 34,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: colors.field,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  height: 36,
                  child: Center(
                    child: Text(
                      'Add',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
