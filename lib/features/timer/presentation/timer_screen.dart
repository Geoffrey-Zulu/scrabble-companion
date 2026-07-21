import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../../../core/settings/settings_notifier.dart';
import '../../../core/widgets/sc_buttons.dart';
import '../../../core/widgets/sc_timer_ring.dart';
import '../application/timer_notifier.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref.read(timerProvider.notifier).pauseForBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final timer = ref.watch(timerProvider);
    final warnAt = ref.watch(settingsProvider.select((s) => s.warnAtSeconds));
    final notifier = ref.read(timerProvider.notifier);
    final inWarn = timer.isInWarning(warnAt);
    final ringColor = timer.isExpired || inWarn
        ? colors.accent
        : (timer.isRunning ? colors.accent : colors.ink);
    final timeColor = timer.isExpired || inWarn ? colors.accent : colors.ink;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageX,
            20,
            AppSpacing.pageX,
            120,
          ),
          child: Column(
            children: [
              Text('Turn Timer', style: textTheme.headlineSmall),
              const SizedBox(height: 18),
              Text(
                'Standalone · start a game to track players by name',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: colors.faint),
              ),
              const Spacer(),
              Semantics(
                label:
                    'Timer ${timer.formattedRemaining}, ${timer.statusLabel}',
                liveRegion: true,
                child: ScTimerRing(
                  progress: timer.progress,
                  color: ringColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: reduceMotion
                            ? Duration.zero
                            : AppMotion.toggle,
                        style:
                            textTheme.displayLarge?.copyWith(
                              color: timeColor,
                            ) ??
                            TextStyle(color: timeColor, fontSize: 74),
                        child: Text(timer.formattedRemaining),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timer.statusLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.faint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScIconButton(
                    icon: Icons.refresh,
                    semanticLabel: 'Reset timer',
                    onPressed: notifier.reset,
                  ),
                  const SizedBox(width: 16),
                  _PlayPauseButton(
                    running: timer.isRunning,
                    onPressed: notifier.toggle,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Wrap(
                spacing: 9,
                children: [
                  for (final seconds in TimerNotifier.durations)
                    _DurationChip(
                      label: _formatDuration(seconds),
                      selected: timer.durationSeconds == seconds,
                      onTap: () => notifier.setDuration(seconds),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({required this.running, required this.onPressed});

  final bool running;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      label: running ? 'Pause timer' : 'Start timer',
      child: Material(
        color: colors.accent,
        shape: const CircleBorder(),
        shadowColor: colors.accent.withValues(alpha: 0.45),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 92,
            height: 92,
            child: Icon(
              running ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 36,
              color: colors.onAccent,
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.accentSoft : colors.field,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: selected ? colors.accent : colors.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
