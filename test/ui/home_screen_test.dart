import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/features/home/presentation/home_screen.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('home shows brand, greeting, and feature cards', (tester) async {
    await pumpSizedApp(tester, home: const HomeScreen());

    expect(find.text('SCRABBLE COMPANION'), findsOneWidget);
    expect(find.textContaining('Good'), findsOneWidget);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('Dictionary'), findsOneWidget);
    expect(find.text('Score Keeper'), findsOneWidget);
    expect(find.text('RECENT GAMES'), findsOneWidget);
    expect(find.text('No games yet'), findsOneWidget);
    expect(find.text('Maya'), findsNothing);
  });

  testWidgets('home does not overflow on short viewports', (tester) async {
    final overflowed = await captureOverflows(tester, () async {
      await pumpSizedApp(
        tester,
        home: const HomeScreen(),
        size: const Size(320, 568),
      );
      await tester.pumpAndSettle();
    });
    expect(overflowed, isFalse);
  });
}
