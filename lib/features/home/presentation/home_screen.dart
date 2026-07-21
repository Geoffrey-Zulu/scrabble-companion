import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../core/widgets/sc_buttons.dart';
import '../../../core/widgets/sc_card.dart';
import '../../../core/widgets/toast_controller.dart';
import '../../timer/application/timer_notifier.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final timer = ref.watch(timerProvider);
    final timerNotifier = ref.read(timerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageX,
            14,
            AppSpacing.pageX,
            120,
          ),
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
            Text(_greeting(), style: textTheme.headlineLarge),
            const SizedBox(height: 26),
            ScCard(
              semanticLabel: 'Open timer',
              onTap: () => context.go('/timer'),
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
              onTap: () => context.go('/dictionary'),
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
                          Text(
                            'Check a word…',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.muted,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
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
              onTap: () {
                ref
                    .read(toastProvider.notifier)
                    .show('Score keeper arrives next');
              },
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
                            Text('No active game', style: textTheme.bodySmall),
                            Text(
                              'Start one',
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
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Text(
                            'New',
                            style: TextStyle(fontWeight: FontWeight.w600),
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
              onPressed: () {
                ref
                    .read(toastProvider.notifier)
                    .show('Score keeper arrives next');
              },
            ),
            const SizedBox(height: AppSpacing.section),
            Text(
              'RECENT GAMES',
              style: textTheme.labelMedium?.copyWith(color: colors.faint),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              child: Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.line, width: 1.5),
                    ),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(
                        Icons.ssid_chart_outlined,
                        color: colors.faint,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No games yet',
                    style: textTheme.bodyMedium?.copyWith(color: colors.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Finished games will appear here.',
                    style: textTheme.bodySmall?.copyWith(color: colors.faint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
