import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/widgets/sc_buttons.dart';
import '../../../core/widgets/sc_card.dart';
import '../../rules/presentation/rules_sheet.dart';
import '../../score_keeper/application/game_notifier.dart';
import '../../score_keeper/domain/game_models.dart';
import '../../score_keeper/presentation/new_game_sheet.dart';
import '../../timer/application/timer_notifier.dart';
import 'recent_games_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 18) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  Future<void> _openNewGame(BuildContext context, WidgetRef ref) async {
    await ref.read(hapticsServiceProvider).medium();
    if (!context.mounted) {
      return;
    }
    final started = await showNewGameSheet(context, ref);
    if (started && context.mounted) {
      context.go('/game');
    }
  }

  Future<void> _openScoreKeeper(BuildContext context, WidgetRef ref) async {
    await ref.read(hapticsServiceProvider).selection();
    if (!context.mounted) {
      return;
    }
    final active = ref.read(gameProvider).value;
    if (active != null && !active.finished) {
      context.go('/game');
      return;
    }
    await _openNewGame(context, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final timer = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);
    final activeGame = ref.watch(gameProvider).value;
    final recentAsync = ref.watch(recentGamesProvider);
    final hasActive = activeGame != null && !activeGame.finished;
    final leader = hasActive
        ? activeGame.players.firstWhere(
            (GamePlayer p) => p.seatIndex == activeGame.leaderSeat,
          )
        : null;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageX,
            14,
            AppSpacing.pageX,
            AppSpacing.scrollBottomClearance,
          ),
          physics: const ClampingScrollPhysics(),
          children: [
            const SizedBox(height: 14),
            Text(
              'SCRABBLE COMPANION',
              style: textTheme.labelMedium?.copyWith(
                color: colors.faint,
                letterSpacing: 0.06 * 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(_greeting(), style: textTheme.headlineLarge),
                ),
                IconButton(
                  tooltip: 'Scrabble rules',
                  onPressed: () {
                    ref.read(hapticsServiceProvider).selection();
                    showScrabbleRulesSheet(context);
                  },
                  icon: Icon(
                    Icons.info_outline_rounded,
                    color: colors.muted,
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            ScCard(
              semanticLabel: 'Open timer',
              onTap: () {
                ref.read(hapticsServiceProvider).selection();
                context.go('/timer');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Timer', style: textTheme.titleSmall),
                      const Spacer(),
                      Icon(Icons.timer_outlined, color: colors.faint, size: 20),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          timer.formattedRemaining,
                          style: textTheme.displayMedium?.copyWith(
                            color: colors.ink,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 44,
                        child: FilledButton(
                          onPressed: () async {
                            if (!timer.isRunning) {
                              await timerNotifier.resumeOrStart();
                            } else {
                              await ref
                                  .read(hapticsServiceProvider)
                                  .selection();
                            }
                            if (context.mounted) {
                              context.go('/timer');
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.accent,
                            foregroundColor: colors.onAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Text(timer.isRunning ? 'Open' : 'Start'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ScCard(
              semanticLabel: 'Open dictionary',
              onTap: () {
                ref.read(hapticsServiceProvider).selection();
                context.go('/dictionary');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Dictionary', style: textTheme.titleSmall),
                      const Spacer(),
                      Icon(
                        Icons.menu_book_outlined,
                        color: colors.faint,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.field,
                      borderRadius: AppRadii.pillBorder,
                    ),
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(Icons.search, size: 18, color: colors.muted),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Check a word…',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyLarge?.copyWith(
                                color: colors.muted,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ScCard(
              semanticLabel: 'Open score keeper',
              onTap: () => _openScoreKeeper(context, ref),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Score Keeper', style: textTheme.titleSmall),
                      const Spacer(),
                      Icon(
                        Icons.ssid_chart_outlined,
                        color: colors.faint,
                        size: 21,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasActive ? 'In progress' : 'No active game',
                              style: textTheme.bodySmall,
                            ),
                            Text(
                              hasActive
                                  ? '${leader!.name} · ${leader.score}'
                                  : 'Start one',
                              style: textTheme.displaySmall?.copyWith(
                                fontSize: 34,
                                color: colors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.field,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Text(
                            hasActive ? 'Resume' : 'New',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            ScPrimaryButton(
              label: 'Start New Game',
              icon: Icons.add,
              expanded: true,
              onPressed: () => _openNewGame(context, ref),
            ),
            const SizedBox(height: AppSpacing.section),
            Text(
              'RECENT GAMES',
              style: textTheme.labelMedium?.copyWith(color: colors.faint),
            ),
            const SizedBox(height: 8),
            recentAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) =>
                  RecentGamesList(games: const [], onGameDeleted: (_) {}),
              data: (games) => RecentGamesList(
                games: games,
                onGameDeleted: (game) {
                  ref.read(hapticsServiceProvider).heavy();
                  ref.read(gameProvider.notifier).deleteRecent(game.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
