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
    notifier.reset();

    final state = container.read(timerProvider);
    expect(state.phase, TimerPhase.idle);
    expect(state.remainingSeconds, 60);
  });

  test('warning detection respects threshold', () {
    const state = TurnTimerState(
      remainingMs: 8 * 1000,
      phase: TimerPhase.running,
    );
    expect(state.isInWarning(10), isTrue);
    expect(state.isInWarning(5), isFalse);
  });

  test('formatted remaining uses mm:ss', () {
    const state = TurnTimerState(remainingMs: 65 * 1000);
    expect(state.formattedRemaining, '1:05');
  });
}
