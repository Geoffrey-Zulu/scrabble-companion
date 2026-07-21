import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/haptics_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/settings/settings_notifier.dart';

enum TimerPhase { idle, running, paused, expired }

class TurnTimerState {
  const TurnTimerState({
    this.durationSeconds = 60,
    this.remainingMs = 60 * 1000,
    this.phase = TimerPhase.idle,
    this.playerIndex = 0,
    this.warned = false,
  });

  final int durationSeconds;
  final int remainingMs;
  final TimerPhase phase;
  final int playerIndex;
  final bool warned;

  bool get isRunning => phase == TimerPhase.running;
  bool get isPaused => phase == TimerPhase.paused;
  bool get isExpired => phase == TimerPhase.expired;
  bool get hasStarted => phase != TimerPhase.idle;

  double get progress {
    if (durationSeconds <= 0) {
      return 0;
    }
    return (remainingMs / (durationSeconds * 1000)).clamp(0, 1);
  }

  int get remainingSeconds => math.max(0, (remainingMs / 1000).ceil());

  bool isInWarning(int warnAtSeconds) {
    return hasStarted &&
        remainingSeconds > 0 &&
        remainingSeconds <= warnAtSeconds;
  }

  String get formattedRemaining {
    final total = remainingSeconds;
    final m = total ~/ 60;
    final s = total % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String get statusLabel => switch (phase) {
    TimerPhase.idle => 'Ready',
    TimerPhase.running => 'Running',
    TimerPhase.paused => 'Paused',
    TimerPhase.expired => 'Time’s up',
  };

  TurnTimerState copyWith({
    int? durationSeconds,
    int? remainingMs,
    TimerPhase? phase,
    int? playerIndex,
    bool? warned,
  }) {
    return TurnTimerState(
      durationSeconds: durationSeconds ?? this.durationSeconds,
      remainingMs: remainingMs ?? this.remainingMs,
      phase: phase ?? this.phase,
      playerIndex: playerIndex ?? this.playerIndex,
      warned: warned ?? this.warned,
    );
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TurnTimerState>(
  TimerNotifier.new,
);

class TimerNotifier extends Notifier<TurnTimerState> {
  static const durations = [30, 60, 120, 180];

  Timer? _ticker;
  Stopwatch? _stopwatch;
  int _baselineMs = 60 * 1000;

  @override
  TurnTimerState build() {
    ref.onDispose(_cancelTicker);
    return const TurnTimerState();
  }

  void setDuration(int seconds) {
    _cancelTicker();
    _stopwatch = null;
    state = TurnTimerState(
      durationSeconds: seconds,
      remainingMs: seconds * 1000,
    );
  }

  Future<void> toggle() async {
    if (state.isRunning) {
      await pause();
    } else {
      await resumeOrStart();
    }
  }

  Future<void> resumeOrStart() async {
    if (state.isExpired) {
      reset();
    }
    _baselineMs = state.remainingMs;
    _stopwatch = Stopwatch()..start();
    state = state.copyWith(phase: TimerPhase.running);
    _startTicker();
    await ref.read(hapticsServiceProvider).medium();
  }

  Future<void> pause() async {
    _syncRemainingFromStopwatch();
    _cancelTicker();
    _stopwatch?.stop();
    state = state.copyWith(phase: TimerPhase.paused);
    await ref.read(hapticsServiceProvider).light();
  }

  /// Fairness policy: freeze the clock when the app backgrounds.
  Future<void> pauseForBackground() async {
    if (!state.isRunning) {
      return;
    }
    await pause();
  }

  void reset() {
    _cancelTicker();
    _stopwatch = null;
    state = TurnTimerState(
      durationSeconds: state.durationSeconds,
      remainingMs: state.durationSeconds * 1000,
      playerIndex: state.playerIndex,
    );
  }

  Future<void> switchPlayer({int? playerCount}) async {
    final count = math.max(1, playerCount ?? 1);
    final next = (state.playerIndex + 1) % count;
    _cancelTicker();
    _stopwatch = null;
    state = TurnTimerState(
      durationSeconds: state.durationSeconds,
      remainingMs: state.durationSeconds * 1000,
      playerIndex: next,
    );
    await ref.read(hapticsServiceProvider).selection();
  }

  void selectPlayer(int index) {
    _cancelTicker();
    _stopwatch = null;
    state = TurnTimerState(
      durationSeconds: state.durationSeconds,
      remainingMs: state.durationSeconds * 1000,
      playerIndex: index,
    );
  }

  void _startTicker() {
    _cancelTicker();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _onTick();
    });
  }

  void _onTick() {
    if (!state.isRunning || _stopwatch == null) {
      return;
    }
    final remaining = math.max(
      0,
      _baselineMs - _stopwatch!.elapsedMilliseconds,
    );
    final warnAt = ref.read(settingsProvider).warnAtSeconds;
    final previousSeconds = state.remainingSeconds;
    final next = state.copyWith(remainingMs: remaining);

    if (remaining <= 0) {
      _expire();
      return;
    }

    final enteredWarn =
        !state.warned &&
        next.remainingSeconds <= warnAt &&
        next.remainingSeconds > 0;
    state = next.copyWith(warned: state.warned || enteredWarn);

    if (enteredWarn) {
      unawaited(ref.read(soundServiceProvider).playWarning());
      unawaited(ref.read(hapticsServiceProvider).medium());
    } else if (state.isInWarning(warnAt) &&
        next.remainingSeconds != previousSeconds) {
      unawaited(ref.read(hapticsServiceProvider).selection());
    }
  }

  void _expire() {
    _cancelTicker();
    _stopwatch?.stop();
    state = state.copyWith(
      remainingMs: 0,
      phase: TimerPhase.expired,
      warned: true,
    );
    unawaited(ref.read(soundServiceProvider).playExpiry());
    unawaited(ref.read(hapticsServiceProvider).heavy());
  }

  void _syncRemainingFromStopwatch() {
    if (_stopwatch == null) {
      return;
    }
    final remaining = math.max(
      0,
      _baselineMs - _stopwatch!.elapsedMilliseconds,
    );
    state = state.copyWith(remainingMs: remaining);
  }

  void _cancelTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}
