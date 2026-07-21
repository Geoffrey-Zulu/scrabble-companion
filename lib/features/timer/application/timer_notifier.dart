import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
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
  /// Preset turn lengths: 30s, 1m, 1m30s, 2m, 3m.
  static const durations = [30, 60, 90, 120, 180];

  /// Default warning threshold if settings are unavailable (e.g. in simple tests).
  static const int warnAtSeconds = 10;

  Timer? _ticker;
  Stopwatch? _stopwatch;
  int _baselineMs = 60 * 1000;

  @override
  TurnTimerState build() {
    ref.onDispose(_cancelTicker);
    return const TurnTimerState();
  }

  int get _warnAtSeconds {
    try {
      return ref.read(settingsProvider).warnAtSeconds;
    } catch (_) {
      return warnAtSeconds;
    }
  }

  void setDuration(int seconds) {
    final nearest = durations.contains(seconds)
        ? seconds
        : durations.reduce(
            (a, b) => (a - seconds).abs() <= (b - seconds).abs() ? a : b,
          );
    _cancelTicker();
    _stopwatch = null;
    unawaited(ref.read(soundServiceProvider).stop());
    state = TurnTimerState(
      durationSeconds: nearest,
      remainingMs: nearest * 1000,
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
      await reset();
    }
    _baselineMs = state.remainingMs;
    _stopwatch = Stopwatch()..start();
    state = state.copyWith(phase: TimerPhase.running);
    _startTicker();
    // Continue a mid-warn chime that was paused with the clock.
    if (state.warned && state.isInWarning(_warnAtSeconds)) {
      unawaited(ref.read(soundServiceProvider).resumePlayback());
    }
    await ref.read(hapticsServiceProvider).medium();
  }

  Future<void> pause() async {
    _syncRemainingFromStopwatch();
    _cancelTicker();
    _stopwatch?.stop();
    await ref.read(soundServiceProvider).pausePlayback();
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

  Future<void> reset() async {
    _cancelTicker();
    _stopwatch = null;
    await ref.read(soundServiceProvider).stop();
    state = TurnTimerState(
      durationSeconds: state.durationSeconds,
      remainingMs: state.durationSeconds * 1000,
      playerIndex: state.playerIndex,
    );
    await ref.read(hapticsServiceProvider).light();
  }

  Future<void> switchPlayer({int? playerCount}) async {
    final count = math.max(1, playerCount ?? 1);
    final next = (state.playerIndex + 1) % count;
    final wasRunning = state.isRunning;

    _cancelTicker();
    _stopwatch = null;
    unawaited(ref.read(soundServiceProvider).stop());

    state = TurnTimerState(
      durationSeconds: state.durationSeconds,
      remainingMs: state.durationSeconds * 1000,
      playerIndex: next,
      phase: wasRunning ? TimerPhase.running : TimerPhase.idle,
    );

    if (wasRunning) {
      _baselineMs = state.remainingMs;
      _stopwatch = Stopwatch()..start();
      _startTicker();
    }

    await ref.read(hapticsServiceProvider).selection();
  }

  void selectPlayer(int index) {
    _cancelTicker();
    _stopwatch = null;
    unawaited(ref.read(soundServiceProvider).stop());
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
    _applyRemaining(remaining);
  }

  /// Applies a remaining-ms sample. Exposed for tests so we can assert warn /
  /// expiry side effects without waiting on a real wall clock.
  @visibleForTesting
  void debugApplyRemaining(int remainingMs) => _applyRemaining(remainingMs);

  void _applyRemaining(int remaining) {
    final warnAt = _warnAtSeconds;
    final previousSeconds = state.remainingSeconds;
    final next = state.copyWith(remainingMs: remaining);

    if (remaining <= 0) {
      _expire();
      return;
    }

    // Fire once when crossing into the warn window - never loop the clip.
    // Asset is longer than [warnAtSeconds]; we stop on reset instead of trimming.
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
    // Warning already started at 10s — do not restart the clip at zero.
    // Stop playback and pulse haptics only.
    unawaited(ref.read(soundServiceProvider).stop());
    unawaited(ref.read(hapticsServiceProvider).expiryPulse());
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
