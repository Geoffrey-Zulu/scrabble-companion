import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/app/app.dart';

void main() {
  testWidgets('app shell shows home greeting and navigates to settings', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(const ProviderScope(child: ScrabbleApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();

    expect(find.textContaining('Good'), findsOneWidget);
    expect(find.text('Check a word…'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('GAMEPLAY'), findsOneWidget);
    expect(find.text('Warning at'), findsOneWidget);
    expect(find.text('Dictionary'), findsWidgets);
  });
}
