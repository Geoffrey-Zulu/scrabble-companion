import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/design.dart';
import '../core/providers.dart';
import '../core/settings/app_settings.dart';
import '../core/settings/settings_notifier.dart';
import '../features/splash/presentation/splash_screen.dart';
import 'router.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  return createAppRouter();
});

class ScrabbleApp extends ConsumerStatefulWidget {
  const ScrabbleApp({super.key});

  @override
  ConsumerState<ScrabbleApp> createState() => _ScrabbleAppState();
}

class _ScrabbleAppState extends ConsumerState<ScrabbleApp> {
  var _showSplash = true;
  var _hydrated = false;

  @override
  Widget build(BuildContext context) {
    ref
      ..watch(settingsBootstrapProvider)
      ..listen(settingsBootstrapProvider, (previous, next) {
        next.whenData((_) {
          _hydrated = true;
        });
      })
      ..listen<AppSettings>(settingsProvider, (previous, next) {
        if (!_hydrated || previous == null) {
          return;
        }
        ref.read(settingsRepositoryProvider).save(next);
      });
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'Scrabble Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (settings.themeMode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      },
      // Soften light ↔ dark swaps (default feels like a hard cut).
      themeAnimationDuration: AppMotion.themeCrossfade,
      themeAnimationCurve: Curves.easeInOutCubic,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final systemFactor = media.textScaler.scale(16) / 16;
        final scaled = media.copyWith(
          textScaler: TextScaler.linear(
            systemFactor * settings.textScale.factor,
          ),
        );

        return MediaQuery(
          data: scaled,
          child: Stack(
            fit: StackFit.expand,
            children: [
              child ?? const SizedBox.shrink(),
              if (_showSplash)
                Positioned.fill(
                  child: SplashScreen(
                    onFinished: () {
                      if (mounted) {
                        setState(() => _showSplash = false);
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      },
      routerConfig: router,
    );
  }
}
