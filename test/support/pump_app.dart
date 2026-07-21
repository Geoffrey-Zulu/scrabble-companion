import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:scrabble_companion/core/design/design.dart';
import 'package:scrabble_companion/core/services/haptics_service.dart';
import 'package:scrabble_companion/core/services/sound_service.dart';
import 'package:scrabble_companion/core/settings/settings_notifier.dart';
import 'package:scrabble_companion/features/home/presentation/recent_games_list.dart';
import 'package:scrabble_companion/features/score_keeper/application/game_notifier.dart';
import 'package:scrabble_companion/features/score_keeper/domain/game_models.dart';

class TestGameNotifier extends GameNotifier {
  @override
  Future<ActiveGame?> build() async => null;
}

List<Override> testServiceOverrides({
  SoundService? sound,
  bool hapticsEnabled = false,
  GameNotifier Function()? createGameNotifier,
}) {
  return [
    soundServiceProvider.overrideWithValue(sound ?? SilentSoundService()),
    hapticsServiceProvider.overrideWithValue(
      HapticsService(isEnabled: () => hapticsEnabled),
    ),
    settingsProvider.overrideWith(SettingsNotifier.new),
    gameProvider.overrideWith(createGameNotifier ?? TestGameNotifier.new),
    recentGamesProvider.overrideWith((ref) async => <RecentGameSummary>[]),
  ];
}

Future<void> pumpSizedApp(
  WidgetTester tester, {
  required Widget home,
  Size size = const Size(390, 844),
  double textScale = 1,
  List<Override> overrides = const [],
  GameNotifier Function()? createGameNotifier,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...testServiceOverrides(createGameNotifier: createGameNotifier),
        ...overrides,
      ],
      child: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: home,
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Captures RenderFlex overflow reports without letting them fail the harness
/// silently - returns true if any overflow was reported during [body].
Future<bool> captureOverflows(
  WidgetTester tester,
  Future<void> Function() body,
) async {
  var overflowed = false;
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.toString().contains('A RenderFlex overflowed')) {
      overflowed = true;
    }
    previous?.call(details);
  };
  try {
    await body();
  } finally {
    FlutterError.onError = previous;
  }
  return overflowed;
}
