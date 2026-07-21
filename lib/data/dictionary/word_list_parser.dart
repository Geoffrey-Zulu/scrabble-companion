/// A single lexicon entry parsed from NWL/CSW/OSPD text.
class WordEntry {
  const WordEntry({
    required this.word,
    required this.definition,
    this.partOfSpeech = '',
    this.example = '',
    this.origin = '',
  });

  final String word;
  final String definition;
  final String partOfSpeech;
  final String example;
  final String origin;

  bool get hasDefinition => definition.trim().isNotEmpty;
}

/// Parses Scrabble companion dictionary line formats.
///
/// Primary (NWL / CSW):
/// `WORD plain definition text [pos INFLECTIONS]`
///
/// Supplemental (OSPD-defs):
/// `WORD pos inflection_fragment definition…`
abstract final class WordListParser {
  static final _primaryLine = RegExp(r'^([A-Z]+)\s+(.*?)\s*(\[[^\]]*\])?\s*$');

  static final _bracketPos = RegExp(r'^\[([^\s\]]+)');

  static final _ospdLine = RegExp(
    r'^([A-Z]+)\s+([a-z]+|interj|prep|conj|pron|article)?\s*(.*)$',
  );

  /// Parses one NWL/CSW line. Returns null for comments / blanks / bad rows.
  static WordEntry? parsePrimaryLine(String raw) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) {
      return null;
    }

    final match = _primaryLine.firstMatch(line);
    if (match == null) {
      // Word-only fallback.
      if (RegExp(r'^[A-Z]+$').hasMatch(line)) {
        return WordEntry(word: line, definition: '');
      }
      return null;
    }

    final word = match.group(1)!;
    var def = (match.group(2) ?? '').trim();
    final bracket = match.group(3);
    var pos = '';
    if (bracket != null) {
      final posMatch = _bracketPos.firstMatch(bracket);
      pos = posMatch?.group(1) ?? '';
    }

    def = _humanizeCrossRefs(def);
    return WordEntry(word: word, definition: def, partOfSpeech: pos);
  }

  /// Parses one ospd-defs line.
  static WordEntry? parseOspdLine(String raw) {
    final line = raw.trimRight();
    if (line.trim().isEmpty) {
      return null;
    }

    final match = _ospdLine.firstMatch(line.trim());
    if (match == null) {
      return null;
    }

    final word = match.group(1)!;
    final pos = (match.group(2) ?? '').trim();
    var rest = (match.group(3) ?? '').trim();

    // Strip leading inflection crumbs until a lowercase definition word-ish.
    // Example: "n pl. -S rough, cindery lava" → pos already captured as n.
    // Example: "v ABASED, ABASING, ABASES to lower…"
    rest = rest.replaceFirst(
      RegExp(r'^(?:pl\.\s+-?[A-Z]+|-[A-Z]+(?:\s+|$)|(?:[A-Z][A-Z,-]*\s+)+)'),
      '',
    );
    rest = rest.trim();

    return WordEntry(word: word, definition: rest, partOfSpeech: pos);
  }

  static String _humanizeCrossRefs(String def) {
    var out = def;
    out = out.replaceAllMapped(
      RegExp(r'\{([^=}=]+)=([a-z]+)\}'),
      (m) => m.group(1)!,
    );
    out = out.replaceAllMapped(
      RegExp('<([^=>=]+)=([a-z]+)>'),
      (m) => 'see ${m.group(1)}',
    );
    return out.trim();
  }
}
