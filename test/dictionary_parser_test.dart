import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/core/settings/app_settings.dart';
import 'package:scrabble_companion/data/dictionary/lexicon.dart';
import 'package:scrabble_companion/data/dictionary/word_list_parser.dart';

void main() {
  group('WordListParser', () {
    test('parses NWL primary lines', () {
      final entry = WordListParser.parsePrimaryLine(
        'QI The circulating life force [n QIS]',
      );
      expect(entry, isNotNull);
      expect(entry!.word, 'QI');
      expect(entry.definition, contains('circulating'));
      expect(entry.partOfSpeech, 'n');
    });

    test('skips comments and blanks', () {
      expect(WordListParser.parsePrimaryLine('# license'), isNull);
      expect(WordListParser.parsePrimaryLine(''), isNull);
    });

    test('humanizes cross references', () {
      final entry = WordListParser.parsePrimaryLine(
        'AD an {advertisement=n} [n ADS]',
      );
      expect(entry!.definition, 'an advertisement');
    });

    test('parses ospd-defs lines', () {
      final entry = WordListParser.parseOspdLine(
        'AA n pl. -S rough, cindery lava',
      );
      expect(entry, isNotNull);
      expect(entry!.word, 'AA');
      expect(entry.partOfSpeech, 'n');
      expect(entry.definition.toLowerCase(), contains('lava'));
    });
  });

  group('Lexicon', () {
    test('suggests by prefix and scores tiles', () {
      const lexicon = Lexicon(
        locale: DictionaryLocale.northAmerican,
        words: {'QI', 'QUIT', 'QUITE', 'ZA'},
        entries: {'QI': WordEntry(word: 'QI', definition: 'life force')},
        sortedWords: ['QI', 'QUIT', 'QUITE', 'ZA'],
      );

      expect(lexicon.isValid('qi'), isTrue);
      expect(lexicon.suggest('QU'), ['QUIT', 'QUITE']);
      expect(Lexicon.points('QI'), 11);
    });
  });
}
