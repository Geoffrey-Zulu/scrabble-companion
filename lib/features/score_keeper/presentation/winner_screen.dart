import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/widgets/sc_buttons.dart';
import '../application/game_notifier.dart';
import '../domain/game_models.dart';
import 'new_game_sheet.dart';

class WinnerScreen extends ConsumerStatefulWidget {
  const WinnerScreen({required this.game, super.key});

  final ActiveGame game;

  @override
  ConsumerState<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends ConsumerState<WinnerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: AppMotion.pop);
    final reduce = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    if (reduce) {
      _enter.value = 1;
    } else {
      _enter.forward();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    await ref.read(hapticsServiceProvider).selection();
    await ref.read(gameProvider.notifier).clearActiveFromMemory();
    if (mounted) {
      context.go('/home');
    }
  }

  Future<void> _newGame() async {
    await ref.read(gameProvider.notifier).clearActiveFromMemory();
    if (!mounted) {
      return;
    }
    final started = await showNewGameSheet(context, ref);
    if (started && mounted) {
      context.go('/game');
    } else if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final winner = widget.game.winner;
    final stats = GameStats.fromGame(widget.game);
    final curved = CurvedAnimation(parent: _enter, curve: AppMotion.emphasized);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 36),
                    FadeTransition(
                      opacity: curved,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.94, end: 1).animate(
                          curved,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'WINNER',
                              style: textTheme.labelMedium?.copyWith(
                                color: colors.accent,
                                letterSpacing: 0.1 * 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              winner.name,
                              textAlign: TextAlign.center,
                              style: textTheme.displaySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${winner.score} points',
                              style: textTheme.titleLarge?.copyWith(
                                color: colors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'GAME STATS',
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.faint,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeTransition(
                      opacity: curved,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.06),
                          end: Offset.zero,
                        ).animate(curved),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _StatCard(
                              label: 'Highest turn',
                              value: '${stats.highestTurn}',
                            ),
                            _StatCard(
                              label: 'Average turn',
                              value: stats.averageTurn.toStringAsFixed(0),
                            ),
                            _StatCard(
                              label: 'Total rounds',
                              value: '${stats.totalRounds}',
                            ),
                            _StatCard(
                              label: 'Duration',
                              value: stats.durationLabel,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ScSecondaryButton(
                      label: 'Done',
                      onPressed: _done,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ScPrimaryButton(
                      label: 'New Game',
                      onPressed: _newGame,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 52 - 12) / 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: colors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(color: colors.faint),
              ),
              const SizedBox(height: 6),
              Text(value, style: textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}
