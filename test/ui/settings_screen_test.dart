import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/features/settings/presentation/settings_screen.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('settings lists gameplay and appearance controls', (
    tester,
  ) async {
    await pumpSizedApp(tester, home: const SettingsScreen());

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('GAMEPLAY'), findsOneWidget);
    expect(find.text('Haptics'), findsOneWidget);
    expect(find.text('Dictionary'), findsWidgets);
  });

  testWidgets('settings stacks option labels above controls', (tester) async {
    await pumpSizedApp(tester, home: const SettingsScreen());

    expect(find.text('Dictionary'), findsWidgets);
    expect(find.text('NWL'), findsOneWidget);
    expect(find.text('CSW'), findsOneWidget);
    expect(find.text('GZ'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Geoffrey Zulu'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Geoffrey Zulu'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsWidgets);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('0.1.0'), findsOneWidget);
  });

  testWidgets('settings scrolls without overflow on short viewport', (
    tester,
  ) async {
    final overflowed = await captureOverflows(tester, () async {
      await pumpSizedApp(
        tester,
        home: const SettingsScreen(),
        size: const Size(320, 568),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
    });
    expect(overflowed, isFalse);
  });
}
