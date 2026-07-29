import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design.dart';
import '../../../core/services/haptics_service.dart';
import '../application/timer_notifier.dart';

/// Compact pause / resume / reset timer chrome for score and shell screens.
class MiniTimerBar extends ConsumerWidget {
  const MiniTimerBar({
    this.forceVisible = false,
    this.showOpenLink = true,
    super.key,
  });

  /// When true, show even if the timer is still idle (score screen).
  final bool forceVisible;

  /// Offer a tap-through to the full timer screen.
  final bool showOpenLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerProvider);
    if (!forceVisible && !timer.hasStarted) {
      return const SizedBox.shrink();
    }

    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final notifier = ref.read(timerProvider.notifier);
    final warn = timer.isInWarning(TimerNotifier.warnAtSeconds);
    final timeColor = timer.isExpired || warn ? colors.invalid : colors.ink;

    return Material(
      color: colors.card,
      child: InkWell(
        onTap: showOpenLink
            ? () {
                ref.read(hapticsServiceProvider).selection();
                context.go('/timer');
              }
            : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.line)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 18, color: colors.muted),
                const SizedBox(width: 8),
                Text(
                  timer.formattedRemaining,
                  style: textTheme.titleMedium?.copyWith(
                    color: timeColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timer.statusLabel,
                  style: textTheme.bodySmall?.copyWith(color: colors.faint),
                ),
                const Spacer(),
                _MiniIconButton(
                  icon: timer.isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  tooltip: timer.isRunning ? 'Pause' : 'Play',
                  onPressed: () {
                    unawaited(ref.read(hapticsServiceProvider).selection());
                    unawaited(notifier.toggle());
                  },
                ),
                _MiniIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Reset',
                  onPressed: () {
                    unawaited(ref.read(hapticsServiceProvider).selection());
                    unawaited(notifier.reset());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  const _MiniIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      onPressed: onPressed,
      icon: Icon(icon, color: colors.ink, size: 22),
    );
  }
}
