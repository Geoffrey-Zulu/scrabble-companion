import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design.dart';
import '../../../core/services/haptics_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/settings/settings_notifier.dart';
import '../../../core/widgets/sc_buttons.dart';
import '../../../core/widgets/sc_timer_ring.dart';
import '../../score_keeper/application/game_notifier.dart';
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
    ref.watch(soundServiceProvider);

    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final timer = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final game = ref.watch(gameProvider).value;
    final players = game?.players ?? [];
    final currentPlayerName = (timer.playerIndex < players.length)
        ? players[timer.playerIndex].name
        : 'Player ${timer.playerIndex + 1}';

    final inWarn = timer.isInWarning(settings.warnAtSeconds);
    final ringColor = timer.isExpired || inWarn
        ? colors.invalid
        : (timer.isRunning ? colors.accent : colors.ink);
    final timeColor = timer.isExpired || inWarn ? colors.invalid : colors.ink;
    final pickerEnabled = !timer.isRunning;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ringSize = math
                .min(280, math.max(180, constraints.maxHeight * 0.34))
                .toDouble();

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageX,
                20,
                AppSpacing.pageX,
                AppSpacing.scrollBottomClearance,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    Text(
                      currentPlayerName.toUpperCase(),
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.muted,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Turn Timer', style: textTheme.headlineSmall),
                    SizedBox(
                      height: math.max(16, constraints.maxHeight * 0.035),
                    ),
                    Semantics(
                      label:
                          'Timer ${timer.formattedRemaining}, ${timer.statusLabel}',
                      liveRegion: true,
                      child: ScTimerRing(
                        size: ringSize,
                        progress: timer.progress,
                        color: ringColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timer.formattedRemaining,
                              style:
                                  textTheme.displayLarge?.copyWith(
                                    color: timeColor,
                                    fontSize: ringSize < 240 ? 52 : 64,
                                  ) ??
                                  TextStyle(
                                    color: timeColor,
                                    fontSize: ringSize < 240 ? 52 : 64,
                                  ),
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
                    SizedBox(
                      height: math.max(12, constraints.maxHeight * 0.03),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScIconButton(
                          icon: Icons.refresh,
                          semanticLabel: 'Reset timer',
                          onPressed: () {
                            unawaited(notifier.reset());
                          },
                        ),
                        const SizedBox(width: 16),
                        _PlayPauseButton(
                          running: timer.isRunning,
                          onPressed: () {
                            unawaited(notifier.toggle());
                          },
                        ),
                        if (players.length > 1) ...[
                          const SizedBox(width: 16),
                          ScIconButton(
                            icon: Icons.skip_next_rounded,
                            semanticLabel: 'Next turn',
                            onPressed: () {
                              unawaited(
                                notifier.switchPlayer(
                                  playerCount: players.length,
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 36),
                    Text(
                      'Duration',
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.faint,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Opacity(
                      opacity: pickerEnabled ? 1 : 0.45,
                      child: IgnorePointer(
                        ignoring: !pickerEnabled,
                        child: _DurationWheel(
                          durationSeconds: timer.durationSeconds,
                          onChanged: (seconds) {
                            notifier.setDuration(seconds);
                            ref.read(hapticsServiceProvider).selection();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// iOS-style drum limited to the preset turn lengths.
class _DurationWheel extends StatefulWidget {
  const _DurationWheel({
    required this.durationSeconds,
    required this.onChanged,
  });

  final int durationSeconds;
  final ValueChanged<int> onChanged;

  @override
  State<_DurationWheel> createState() => _DurationWheelState();
}

class _DurationWheelState extends State<_DurationWheel> {
  late final FixedExtentScrollController _controller;
  var _suppressNotify = false;

  static String _label(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  static int _presetIndex(int seconds) {
    final index = TimerNotifier.durations.indexOf(seconds);
    return index < 0 ? 1 : index;
  }

  static int _normalizeIndex(int index) {
    final n = TimerNotifier.durations.length;
    return ((index % n) + n) % n;
  }

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: _presetIndex(widget.durationSeconds),
    );
  }

  @override
  void didUpdateWidget(covariant _DurationWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.durationSeconds == widget.durationSeconds) {
      return;
    }
    final target = _presetIndex(widget.durationSeconds);
    if (!_controller.hasClients) {
      return;
    }
    if (_normalizeIndex(_controller.selectedItem) == target) {
      return;
    }
    // Never jump during the parent rebuild that setDuration just triggered -
    // that re-enters onSelectedItemChanged and blows up Riverpod.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) {
        return;
      }
      final current = _controller.selectedItem;
      final delta = target - _normalizeIndex(current);
      if (delta == 0) {
        return;
      }
      _suppressNotify = true;
      _controller.jumpToItem(current + delta);
      _suppressNotify = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final brightness = Theme.of(context).brightness;

    return Semantics(
      label: 'Turn duration',
      child: SizedBox(
        height: 168,
        child: CupertinoTheme(
          data: CupertinoThemeData(
            brightness: brightness,
            primaryColor: colors.accent,
            textTheme: CupertinoTextThemeData(
              pickerTextStyle: TextStyle(
                color: colors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          child: CupertinoPicker(
            scrollController: _controller,
            itemExtent: 46,
            diameterRatio: 1.5,
            magnification: 1.14,
            useMagnifier: true,
            squeeze: 0.9,
            looping: true,
            onSelectedItemChanged: (index) {
              if (_suppressNotify) {
                return;
              }
              const presets = TimerNotifier.durations;
              final seconds = presets[_normalizeIndex(index)];
              if (seconds == widget.durationSeconds) {
                return;
              }
              // Defer so we never mutate a provider mid-build.
              Future<void>(() {
                if (!mounted) {
                  return;
                }
                widget.onChanged(seconds);
              });
            },
            children: [
              for (final seconds in TimerNotifier.durations)
                Center(child: Text(_label(seconds))),
            ],
          ),
        ),
      ),
    );
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
