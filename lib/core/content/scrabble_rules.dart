/// Official Scrabble rules content for the in-app Rules sheet.
///
/// Sourced from the project `rules.txt` handoff (now removed).
abstract final class ScrabbleRules {
  static const title = 'Scrabble Rules';

  static const subtitle = 'Official overview for casual & club play';

  static const sections = <ScrabbleRulesSection>[
    ScrabbleRulesSection(
      title: 'Object of the game',
      body:
          'Two to four players take turns forming words on the board. '
          'The goal is to score more points than everyone else. Each letter '
          'has its own point value - the main strategy is to play the highest '
          'scoring words you can from the tiles you hold.',
    ),
    ScrabbleRulesSection(
      title: 'The board',
      body:
          'A standard Scrabble board is a 15×15 grid. Each tile fits in one '
          'cell. Premium squares multiply letter or word scores when used '
          'for the first time.',
    ),
    ScrabbleRulesSection(
      title: 'The tiles',
      body:
          'There are 100 tiles: 98 with letters and point values, plus '
          '2 blanks. A blank is a wild tile that can stand for any letter '
          'and stays as that letter for the rest of the game. Blanks score '
          '0 points. Harder letters are worth more.',
    ),
    ScrabbleRulesSection(
      title: 'Letter values',
      body:
          '0 - Blank\n'
          '1 - A, E, I, L, N, O, R, S, T, U\n'
          '2 - D, G\n'
          '3 - B, C, M, P\n'
          '4 - F, H, V, W, Y\n'
          '5 - K\n'
          '8 - J, X\n'
          '10 - Q, Z',
    ),
    ScrabbleRulesSection(
      title: 'Premium squares',
      body:
          'Double Letter (light blue) - doubles that tile.\n'
          'Triple Letter (dark blue) - triples that tile.\n'
          'Double Word (light red) - doubles the whole word; runs toward '
          'the corners.\n'
          'Triple Word (dark red) - triples the whole word; on each side '
          'of the board.\n\n'
          'Each premium square only multiplies the first time a tile is '
          'played on it.',
    ),
    ScrabbleRulesSection(
      title: 'Starting the game',
      body:
          'Each player draws one tile; closest to “A” goes first (blank '
          'wins the draw). Return those tiles, then each player draws '
          'seven. On a turn you may place a word, exchange tiles, or pass. '
          'Exchanging ends your turn with no score. Two passes in a row '
          'from any player end the game - highest score wins.',
    ),
    ScrabbleRulesSection(
      title: 'The first word',
      body:
          'The first word must cover the center star (a double-word square). '
          'Later words must connect to tiles already on the board. Play '
          'continues clockwise.',
    ),
    ScrabbleRulesSection(
      title: 'Replacing tiles',
      body:
          'After you play, draw tiles so you again hold seven (while the '
          'bag still has tiles). Always draw without looking.',
    ),
    ScrabbleRulesSection(
      title: 'Bingo - 50 point bonus',
      body:
          'Using all seven tiles in one play scores a 50-point bonus on '
          'top of the word. Near the end, if you hold fewer than seven '
          'tiles, you do not get this bonus for emptying your rack.',
    ),
    ScrabbleRulesSection(
      title: 'Ending the game',
      body:
          'When the bag is empty and one player has used all their tiles, '
          'the game ends. Each player subtracts the face value of tiles '
          'still on their rack. The player who went out adds those '
          'deducted values to their score. Highest final total wins.',
    ),
    ScrabbleRulesSection(
      title: 'Allowed words',
      body:
          'Words in a standard English dictionary (or an official Scrabble '
          'dictionary) are allowed. Not allowed: suffixes/prefixes alone, '
          'abbreviations, hyphenated or apostrophe words, or words that '
          'require a capital letter. Foreign words are only allowed if '
          'they appear in a standard English dictionary.',
    ),
  ];
}

class ScrabbleRulesSection {
  const ScrabbleRulesSection({required this.title, required this.body});

  final String title;
  final String body;
}
