import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design/design.dart';
import '../core/services/haptics_service.dart';
import '../core/widgets/sc_bottom_nav.dart';
import '../core/widgets/sc_toast.dart';
import '../features/dictionary/presentation/dictionary_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/score_keeper/domain/game_models.dart';
import '../features/score_keeper/presentation/score_screen.dart';
import '../features/score_keeper/presentation/winner_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/timer/presentation/timer_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

CustomTransitionPage<void> _fadeUpPage({
  required LocalKey key,
  required Widget child,
  Duration duration = AppMotion.fadeIn,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: AppMotion.fadeIn,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.emphasized,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.035),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

GoRouter createAppRouter({String initialLocation = '/home'}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timer',
                name: 'timer',
                builder: (context, state) => const TimerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dictionary',
                name: 'dictionary',
                builder: (context, state) => const DictionaryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/game',
        name: 'game',
        pageBuilder: (context, state) =>
            _fadeUpPage(key: state.pageKey, child: const ScoreScreen()),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/game/winner',
        name: 'game-winner',
        pageBuilder: (context, state) {
          final game = state.extra;
          final child = game is ActiveGame
              ? WinnerScreen(game: game)
              : const ScoreScreen();
          return _fadeUpPage(
            key: state.pageKey,
            child: child,
            duration: AppMotion.pop,
          );
        },
      ),
    ],
  );
}

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(children: [navigationShell, const ScToastHost()]),
      bottomNavigationBar: ScBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          ref.read(hapticsServiceProvider).selection();
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
