import '../../core/settings/app_settings.dart';
import 'word_list_parser.dart';

/// In-memory lexicon for fast offline validity + definition lookup.
class Lexicon {
  const Lexicon({
    required this.locale,
    required this.words,
    required this.entries,
    required this.sortedWords,
  });

  final DictionaryLocale locale;
  final Set<String> words;
  final Map<String, WordEntry> entries;
  final List<String> sortedWords;

  int get wordCount => words.length;

  bool isValid(String word) => words.contains(word.toUpperCase());

  WordEntry? entry(String word) => entries[word.toUpperCase()];

  /// Prefix suggestions sorted by length then alpha. Caps at [limit].
  List<String> suggest(String prefix, {int limit = 5}) {
    final p = prefix.toUpperCase();
    if (p.isEmpty) {
      return const [];
    }

    var lo = 0;
    var hi = sortedWords.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (sortedWords[mid].compareTo(p) < 0) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }

    final out = <String>[];
    for (var i = lo; i < sortedWords.length; i++) {
      final w = sortedWords[i];
      if (!w.startsWith(p)) {
        break;
      }
      if (w == p) {
        continue;
      }
      out.add(w);
      if (out.length >= limit * 4) {
        break;
      }
    }

    out.sort((a, b) {
      final byLen = a.length.compareTo(b.length);
      return byLen != 0 ? byLen : a.compareTo(b);
    });
    return out.take(limit).toList(growable: false);
  }

  /// Standard English Scrabble tile values (no premium squares).
  static int points(String word) {
    const values = <String, int>{
      'A': 1,
      'B': 3,
      'C': 3,
      'D': 2,
      'E': 1,
      'F': 4,
      'G': 2,
      'H': 4,
      'I': 1,
      'J': 8,
      'K': 5,
      'L': 1,
      'M': 3,
      'N': 1,
      'O': 1,
      'P': 3,
      'Q': 10,
      'R': 1,
      'S': 1,
      'T': 1,
      'U': 1,
      'V': 4,
      'W': 4,
      'X': 8,
      'Y': 4,
      'Z': 10,
    };
    var total = 0;
    for (final code in word.toUpperCase().codeUnits) {
      total += values[String.fromCharCode(code)] ?? 0;
    }
    return total;
  }
}
