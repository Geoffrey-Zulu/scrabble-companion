import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/features/score_keeper/domain/game_models.dart';
import 'package:scrabble_companion/features/score_keeper/presentation/new_game_sheet.dart';

import '../support/pump_app.dart';

class _RecordingGameNotifier extends TestGameNotifier {
  List<String>? lastNames;

  @override
  Future<ActiveGame> startGame(List<String> rawNames) async {
    lastNames = rawNames;
    final names = <String>[];
    for (var i = 0; i < rawNames.length; i++) {
      final trimmed = rawNames[i].trim();
      names.add(trimmed.isEmpty ? 'Player ${i + 1}' : trimmed);
    }
    final game = ActiveGame(
      id: 'test-game',
      startedAt: DateTime(2026),
      players: [
        for (var i = 0; i < names.length; i++)
          GamePlayer(seatIndex: i, name: names[i]),
      ],
    );
    state = AsyncData(game);
    return game;
  }
}

void main() {
  Future<_RecordingGameNotifier> pumpSheet(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    final notifier = _RecordingGameNotifier();
    await pumpSizedApp(
      tester,
      size: size,
      createGameNotifier: () => notifier,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: TextButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const NewGameSheet(),
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
    return notifier;
  }

  testWidgets('new game sheet starts with two player fields', (tester) async {
    await pumpSheet(tester);
    expect(find.text('New Game'), findsOneWidget);
    expect(find.text('2 players · 2–6'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('adding players up to 6 does not overflow short screens', (
    tester,
  ) async {
    final overflowed = await captureOverflows(tester, () async {
      await pumpSheet(tester, size: const Size(320, 568));

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byKey(const Key('add-player')));
        await tester.pumpAndSettle();
      }

      expect(find.text('6 players · 2–6'), findsOneWidget);
      // Off-stage list children are fine — proves the list scrolls instead of overflowing.
      expect(find.byType(TextField, skipOffstage: false), findsNWidgets(6));
      expect(find.byKey(const Key('add-player')), findsNothing);

      // Scroll the player list — still no overflow.
      await tester.drag(find.byType(ListView).first, const Offset(0, -120));
      await tester.pumpAndSettle();
    });

    expect(overflowed, isFalse);
  });

  testWidgets('add player focuses the new text field', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.byKey(const Key('add-player')));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(3));
    final third = tester.widget<TextField>(
      find.byKey(const ValueKey('player-field-2')),
    );
    expect(third.focusNode?.hasFocus, isTrue);
  });

  testWidgets('remove player keeps at least two fields', (tester) async {
    await pumpSheet(tester);

    await tester.tap(find.byKey(const Key('add-player')));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byTooltip('Remove player'), findsNWidgets(3));

    await tester.tap(find.byTooltip('Remove player').first);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    // At minimum 2, remove buttons hidden.
    expect(find.byTooltip('Remove player'), findsNothing);
  });

  testWidgets('start game uses blank defaults as Player N', (tester) async {
    final notifier = await pumpSheet(tester);

    await tester.tap(find.text('Start Game'));
    await tester.pumpAndSettle();

    expect(notifier.lastNames, ['', '']);
    // Sheet dismissed after start.
    expect(find.text('New Game'), findsNothing);
  });
}
