import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/settings/app_settings.dart';
import 'lexicon.dart';
import 'word_list_parser.dart';

/// Loads and caches lexicons from bundled assets.
class LexiconLoader {
  Lexicon? _active;
  DictionaryLocale? _activeLocale;

  Lexicon? get active => _active;

  Future<Lexicon> load(DictionaryLocale locale) async {
    if (_active != null && _activeLocale == locale) {
      return _active!;
    }

    final primaryPath = switch (locale) {
      DictionaryLocale.northAmerican => 'assets/dictionaries/nwl2023.txt',
      DictionaryLocale.british => 'assets/dictionaries/csw21.txt',
    };

    final primaryText = await rootBundle.loadString(primaryPath);
    final ospdText = await rootBundle.loadString(
      'assets/dictionaries/ospd-defs.txt',
    );

    final lexicon = await compute(_parseBundle, (
      locale,
      primaryText,
      ospdText,
    ));

    _active = lexicon;
    _activeLocale = locale;
    return lexicon;
  }

  void clear() {
    _active = null;
    _activeLocale = null;
  }
}

Lexicon _parseBundle((DictionaryLocale, String, String) args) {
  final (locale, primaryText, ospdText) = args;
  final words = <String>{};
  final entries = <String, WordEntry>{};
  var skipped = 0;

  for (final line in primaryText.split('\n')) {
    final entry = WordListParser.parsePrimaryLine(line);
    if (entry == null) {
      if (line.trim().isNotEmpty && !line.trimLeft().startsWith('#')) {
        skipped++;
      }
      continue;
    }
    words.add(entry.word);
    entries[entry.word] = entry;
  }

  for (final line in ospdText.split('\n')) {
    final ospd = WordListParser.parseOspdLine(line);
    if (ospd == null) {
      continue;
    }
    final existing = entries[ospd.word];
    if (existing == null) {
      continue;
    }
    final needsEnrichment =
        !existing.hasDefinition ||
        existing.definition.toLowerCase().startsWith('see ');
    if (needsEnrichment && ospd.hasDefinition) {
      entries[ospd.word] = WordEntry(
        word: existing.word,
        definition: ospd.definition,
        partOfSpeech: existing.partOfSpeech.isNotEmpty
            ? existing.partOfSpeech
            : ospd.partOfSpeech,
      );
    }
  }

  final sorted = words.toList()..sort();
  assert(() {
    debugPrint(
      'Lexicon ${locale.name}: ${words.length} words '
      '($skipped primary lines skipped)',
    );
    return true;
  }());

  return Lexicon(
    locale: locale,
    words: words,
    entries: entries,
    sortedWords: sorted,
  );
}
