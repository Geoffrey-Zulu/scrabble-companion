import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/core/providers.dart';
import 'package:scrabble_companion/core/settings/app_settings.dart';
import 'package:scrabble_companion/data/dictionary/lexicon.dart';
import 'package:scrabble_companion/features/dictionary/application/dictionary_controller.dart';
import 'package:scrabble_companion/features/dictionary/presentation/dictionary_screen.dart';

import '../support/pump_app.dart';

class _UiOnlyDictionaryController extends DictionaryController {
  @override
  DictionaryUiState build() => const DictionaryUiState();
}

void main() {
  const emptyLexicon = Lexicon(
    locale: DictionaryLocale.northAmerican,
    words: {'QI'},
    entries: {},
    sortedWords: ['QI'],
  );

  testWidgets('dictionary shows checker chrome', (tester) async {
    await pumpSizedApp(
      tester,
      home: const DictionaryScreen(),
      overrides: [
        dictionaryControllerProvider.overrideWith(
          _UiOnlyDictionaryController.new,
        ),
        lexiconProvider.overrideWith((ref) async => emptyLexicon),
      ],
    );
    await tester.pump();

    expect(find.text('Word Checker'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('dictionary does not overflow on short viewport', (tester) async {
    final overflowed = await captureOverflows(tester, () async {
      await pumpSizedApp(
        tester,
        home: const DictionaryScreen(),
        size: const Size(320, 568),
        overrides: [
          dictionaryControllerProvider.overrideWith(
            _UiOnlyDictionaryController.new,
          ),
          lexiconProvider.overrideWith((ref) async => emptyLexicon),
        ],
      );
      await tester.pump();
    });
    expect(overflowed, isFalse);
  });
}
