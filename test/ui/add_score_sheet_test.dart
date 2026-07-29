import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/core/providers.dart';
import 'package:scrabble_companion/core/settings/app_settings.dart';
import 'package:scrabble_companion/data/dictionary/lexicon.dart';
import 'package:scrabble_companion/data/dictionary/word_list_parser.dart';
import 'package:scrabble_companion/features/score_keeper/domain/game_models.dart';
import 'package:scrabble_companion/features/score_keeper/presentation/add_score_sheet.dart';

import '../support/pump_app.dart';

void main() {
  const player = GamePlayer(seatIndex: 0, name: 'Ada', score: 12);

  const testLexicon = Lexicon(
    locale: DictionaryLocale.northAmerican,
    words: {'CAT', 'QUIZ'},
    entries: <String, WordEntry>{},
    sortedWords: ['CAT', 'QUIZ'],
  );

  Future<({int points, String? word})?> openSheet(
    WidgetTester tester, {
    Size size = const Size(390, 700),
    double keyboardInset = 0,
    int? initialPoints,
    String? initialWord,
    String submitLabel = 'Add Score',
    String? titleOverride,
  }) async {
    ({int points, String? word})? result;
    await pumpSizedApp(
      tester,
      size: size,
      overrides: [lexiconProvider.overrideWith((ref) async => testLexicon)],
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
                  onPressed: () async {
                    result = await showAddScoreSheet(
                      context: context,
                      player: player,
                      round: 2,
                      initialPoints: initialPoints,
                      initialWord: initialWord,
                      submitLabel: submitLabel,
                      titleOverride: titleOverride,
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
    return result;
  }

  testWidgets('add score sheet does not overflow with keyboard inset', (
    tester,
  ) async {
    final overflowed = await captureOverflows(tester, () async {
      await openSheet(tester, size: const Size(360, 640), keyboardInset: 280);
      await tester.enterText(find.byType(TextField), 'WORD');
      await tester.pumpAndSettle();
    });
    expect(overflowed, isFalse);
    expect(find.text("Ada's turn"), findsOneWidget);
    expect(find.text('Optional word'), findsOneWidget);
    expect(find.text('+ Add'), findsOneWidget);
    expect(find.text('− Subtract'), findsOneWidget);
  });

  testWidgets('edit mode seeds points and word', (tester) async {
    await openSheet(
      tester,
      initialPoints: 18,
      initialWord: 'CAT',
      submitLabel: 'Save',
      titleOverride: 'Edit Ada',
    );

    expect(find.text('Edit Ada'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('CAT'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('subtract mode submits negative points', (tester) async {
    ({int points, String? word})? result;
    await pumpSizedApp(
      tester,
      overrides: [lexiconProvider.overrideWith((ref) async => testLexicon)],
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: TextButton(
                onPressed: () async {
                  result = await showAddScoreSheet(
                    context: context,
                    player: player,
                    round: 1,
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

    await tester.tap(find.text('− Subtract'));
    await tester.pump();
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    expect(find.text('-12'), findsOneWidget);

    await tester.tap(find.text('Add Score'));
    await tester.pumpAndSettle();
    expect(result?.points, -12);
  });

  testWidgets('tapping empty sheet area dismisses when keyboard is closed', (
    tester,
  ) async {
    await openSheet(tester);
    expect(find.text("Ada's turn"), findsOneWidget);

    // Tap the title/empty chrome — should dismiss the tray.
    await tester.tap(find.text("Ada's turn"));
    await tester.pumpAndSettle();
    expect(find.text("Ada's turn"), findsNothing);
  });

  testWidgets('check word shows validity for lexicon entry', (tester) async {
    await openSheet(tester);
    await tester.enterText(find.byType(TextField), 'CAT');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Check word'));
    await tester.pumpAndSettle();
    expect(find.text('CAT is valid'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ZZZZ');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Check word'));
    await tester.pumpAndSettle();
    expect(find.text('ZZZZ is not valid'), findsOneWidget);
  });
}
