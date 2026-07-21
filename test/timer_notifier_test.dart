import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/core/services/haptics_service.dart';
import 'package:scrabble_companion/core/services/sound_service.dart';
import 'package:scrabble_companion/core/settings/settings_notifier.dart';
import 'package:scrabble_companion/features/timer/application/timer_notifier.dart';

void main() {
  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [
        hapticsServiceProvider.overrideWithValue(
          HapticsService(isEnabled: () => false),
        ),
        soundServiceProvider.overrideWithValue(SilentSoundService()),
        settingsProvider.overrideWith(SettingsNotifier.new),
      ],
    );
  }

  test('setDuration resets remaining and phase', () {
    final container = makeContainer();
    addTearDown(container.dispose);
    container.read(timerProvider.notifier).setDuration(120);
    final state = container.read(timerProvider);
    expect(state.durationSeconds, 120);
    expect(state.remainingSeconds, 120);
    expect(state.phase, TimerPhase.idle);
  });

  test('setDuration snaps to nearest preset', () {
    final container = makeContainer();
    addTearDown(container.dispose);
    container.read(timerProvider.notifier).setDuration(50);
    expect(container.read(timerProvider).durationSeconds, 60);

    container.read(timerProvider.notifier).setDuration(100);
    expect(container.read(timerProvider).durationSeconds, 90);
  });

  test('toggle starts then pauses', () async {
    final container = makeContainer();
    addTearDown(container.dispose);
    final notifier = container.read(timerProvider.notifier);

    await notifier.toggle();
    expect(container.read(timerProvider).isRunning, isTrue);

    await notifier.toggle();
    expect(container.read(timerProvider).isPaused, isTrue);
    expect(
      container.read(timerProvider).remainingSeconds,
      lessThanOrEqualTo(60),
    );
  });

  test('reset restores full duration', () async {
    final container = makeContainer();
    addTearDown(container.dispose);
    final notifier = container.read(timerProvider.notifier);

    await notifier.resumeOrStart();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await notifier.reset();

    final state = container.read(timerProvider);
    expect(state.phase, TimerPhase.idle);
    expect(state.remainingSeconds, 60);
  });

  test('warning detection uses hard-coded 10s threshold', () {
    const state = TurnTimerState(
      remainingMs: 10 * 1000,
      phase: TimerPhase.running,
    );
    expect(state.isInWarning(TimerNotifier.warnAtSeconds), isTrue);
    expect(
      const TurnTimerState(
        remainingMs: 11 * 1000,
        phase: TimerPhase.running,
      ).isInWarning(TimerNotifier.warnAtSeconds),
      isFalse,
    );
  });

  test('formatted remaining uses mm:ss', () {
    const state = TurnTimerState(remainingMs: 65 * 1000);
    expect(state.formattedRemaining, '1:05');
  });

  test('plays warning once at 10s, expiry on zero', () async {
    final sound = RecordingSoundService();
    final container = ProviderContainer(
      overrides: [
        hapticsServiceProvider.overrideWithValue(
          HapticsService(isEnabled: () => false),
        ),
        soundServiceProvider.overrideWithValue(sound),
        settingsProvider.overrideWith(SettingsNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(timerProvider.notifier);
    await notifier.resumeOrStart();

    notifier.debugApplyRemaining(20 * 1000);
    expect(sound.events, isEmpty);

    notifier.debugApplyRemaining(10 * 1000);
    expect(sound.events, ['warning']);
    expect(container.read(timerProvider).warned, isTrue);

    notifier
      ..debugApplyRemaining(5 * 1000)
      ..debugApplyRemaining(0);
    expect(sound.events, ['warning', 'expiry']);
    expect(container.read(timerProvider).isExpired, isTrue);
  });

  test('pause pauses warning sound; resume continues it', () async {
    final sound = RecordingSoundService();
    final container = ProviderContainer(
      overrides: [
        hapticsServiceProvider.overrideWithValue(
          HapticsService(isEnabled: () => false),
        ),
        soundServiceProvider.overrideWithValue(sound),
        settingsProvider.overrideWith(SettingsNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(timerProvider.notifier);
    await notifier.resumeOrStart();
    notifier.debugApplyRemaining(10 * 1000);
    expect(sound.events, ['warning']);

    await notifier.pause();
    expect(sound.events, ['warning', 'pause']);
    expect(container.read(timerProvider).isPaused, isTrue);

    // Re-assert warn window after pause sync (stopwatch would otherwise drift).
    notifier.debugApplyRemaining(10 * 1000);
    await notifier.resumeOrStart();
    expect(sound.events, ['warning', 'pause', 'resume']);
    expect(container.read(timerProvider).isRunning, isTrue);
  });

  test('reset stops warning sound', () async {
    final sound = RecordingSoundService();
    final container = ProviderContainer(
      overrides: [
        hapticsServiceProvider.overrideWithValue(
          HapticsService(isEnabled: () => false),
        ),
        soundServiceProvider.overrideWithValue(sound),
        settingsProvider.overrideWith(SettingsNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(timerProvider.notifier);
    await notifier.resumeOrStart();
    notifier.debugApplyRemaining(10 * 1000);
    expect(sound.events, ['warning']);

    await notifier.reset();
    expect(sound.events, ['warning', 'stop']);
    expect(container.read(timerProvider).remainingSeconds, 60);
  });
}
