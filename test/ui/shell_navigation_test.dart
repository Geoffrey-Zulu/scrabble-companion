import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/app/app.dart';
import 'package:scrabble_companion/core/widgets/sc_bottom_nav.dart';

import '../support/pump_app.dart';

void main() {
  Future<void> pumpShell(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: testServiceOverrides(),
        child: const ScrabbleApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
  }

  Finder navLabel(String label) {
    return find.descendant(
      of: find.byType(ScBottomNav),
      matching: find.text(label),
    );
  }

  testWidgets('shell navigates across all primary tabs', (tester) async {
    await pumpShell(tester);

    expect(find.textContaining('Good'), findsOneWidget);

    await tester.tap(navLabel('Timer'));
    await tester.pumpAndSettle();
    expect(find.text('Turn Timer'), findsOneWidget);

    await tester.tap(navLabel('Dictionary'));
    await tester.pumpAndSettle();
    expect(find.text('Word Checker'), findsOneWidget);

    await tester.tap(navLabel('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('GAMEPLAY'), findsOneWidget);

    await tester.tap(navLabel('Home'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Good'), findsOneWidget);
  });

  testWidgets('shell tabs fit short viewport without overflow', (tester) async {
    var overflowed = false;
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.toString().contains('A RenderFlex overflowed')) {
        overflowed = true;
      }
      previous?.call(details);
    };
    addTearDown(() => FlutterError.onError = previous);

    await pumpShell(tester, size: const Size(320, 568));

    for (final tab in ['Timer', 'Dictionary', 'Settings', 'Home']) {
      await tester.tap(navLabel(tab));
      await tester.pumpAndSettle();
    }

    expect(overflowed, isFalse);
  });
}
