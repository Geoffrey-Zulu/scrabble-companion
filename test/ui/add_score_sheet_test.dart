import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/features/score_keeper/domain/game_models.dart';
import 'package:scrabble_companion/features/score_keeper/presentation/add_score_sheet.dart';

import '../support/pump_app.dart';

void main() {
  const player = GamePlayer(seatIndex: 0, name: 'Ada', score: 12);

  Future<void> openSheet(
    WidgetTester tester, {
    Size size = const Size(390, 700),
    double keyboardInset = 0,
  }) async {
    await pumpSizedApp(
      tester,
      size: size,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          viewInsets: EdgeInsets.only(bottom: keyboardInset),
        ),
        child: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: TextButton(
                  onPressed: () {
                    showAddScoreSheet(
                      context: context,
                      player: player,
                      round: 2,
                    );
                  },
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('add score sheet does not overflow with keyboard inset', (
    tester,
  ) async {
    final overflowed = await captureOverflows(tester, () async {
      await openSheet(
        tester,
        size: const Size(360, 640),
        keyboardInset: 280,
      );
      await tester.enterText(find.byType(TextField), 'WORD');
      await tester.pumpAndSettle();
    });
    expect(overflowed, isFalse);
    expect(find.text("Ada's turn"), findsOneWidget);
    expect(find.text('Optional word'), findsOneWidget);
  });

  testWidgets('edit mode seeds points and word', (tester) async {
    await pumpSizedApp(
      tester,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: TextButton(
                onPressed: () {
                  showAddScoreSheet(
                    context: context,
                    player: player,
                    round: 3,
                    initialPoints: 18,
                    initialWord: 'CAT',
                    submitLabel: 'Save',
                    titleOverride: 'Edit Ada',
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Ada'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('CAT'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
