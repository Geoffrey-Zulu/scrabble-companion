import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/core/widgets/sc_timer_ring.dart';
import 'package:scrabble_companion/features/timer/application/timer_notifier.dart';
import 'package:scrabble_companion/features/timer/presentation/timer_screen.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('timer screen renders ring, controls, and duration wheel', (
    tester,
  ) async {
    await pumpSizedApp(tester, home: const TimerScreen());

    expect(find.text('Turn Timer'), findsOneWidget);
    expect(find.byType(ScTimerRing), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byType(CupertinoPicker), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('1:00'), findsWidgets);
  });

  testWidgets('timer screen does not overflow on short viewports', (
    tester,
  ) async {
    const sizes = <Size>[
      Size(320, 568),
      Size(360, 640),
      Size(390, 700),
    ];

    for (final size in sizes) {
      final overflowed = await captureOverflows(tester, () async {
        await pumpSizedApp(tester, home: const TimerScreen(), size: size);
        await tester.pumpAndSettle();
      });
      expect(overflowed, isFalse, reason: 'overflow at $size');
    }
  });

  testWidgets('play toggles to pause affordance', (tester) async {
    await pumpSizedApp(tester, home: const TimerScreen());

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
  });

  testWidgets('expiry reaches Time’s up without screen flash overlay', (
    tester,
  ) async {
    await pumpSizedApp(tester, home: const TimerScreen());
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TimerScreen)),
    );

    await container.read(timerProvider.notifier).resumeOrStart();
    await tester.pump();
    container.read(timerProvider.notifier).debugApplyRemaining(0);
    await tester.pump();

    expect(container.read(timerProvider).isExpired, isTrue);
    expect(find.textContaining('Time'), findsWidgets);
  });
}
