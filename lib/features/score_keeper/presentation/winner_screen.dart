import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/widgets/sc_buttons.dart';
import '../domain/game_models.dart';
import 'new_game_sheet.dart';

class WinnerScreen extends ConsumerWidget {
  const WinnerScreen({required this.game, super.key});

  final ActiveGame game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final winner = game.winner;
    final stats = GameStats.fromGame(game);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Winner',
                style: textTheme.labelMedium?.copyWith(color: colors.faint),
              ),
              const SizedBox(height: 8),
              Text(winner.name, style: textTheme.displaySmall),
              Text(
                '${winner.score} points',
                style: textTheme.titleLarge?.copyWith(color: colors.muted),
              ),
              const SizedBox(height: 28),
              Wrap(
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
                  _StatCard(label: 'Duration', value: stats.durationLabel),
                ],
              ),
              const Spacer(),
              ScPrimaryButton(
                label: 'Done',
                expanded: true,
                onPressed: () {
                  ref.read(hapticsServiceProvider).selection();
                  context.go('/home');
                },
              ),
              const SizedBox(height: 12),
              ScSecondaryButton(
                label: 'New Game',
                expanded: true,
                onPressed: () async {
                  final started = await showNewGameSheet(context, ref);
                  if (started && context.mounted) {
                    context.go('/game');
                  }
                },
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
