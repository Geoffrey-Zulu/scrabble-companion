import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:scrabble_companion/core/design/design.dart';
import 'package:scrabble_companion/features/timer/presentation/mini_timer_bar.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('forceVisible shows idle controls on score-style screens', (
    tester,
  ) async {
    await pumpSizedApp(
      tester,
      home: const Scaffold(
        body: Column(
          children: [
            MiniTimerBar(forceVisible: true, showOpenLink: false),
            Expanded(child: SizedBox()),
          ],
        ),
      ),
    );

    expect(find.text('1:00'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byTooltip('Play'), findsOneWidget);
    expect(find.byTooltip('Reset'), findsOneWidget);
  });

  testWidgets('hidden when idle unless forceVisible', (tester) async {
    await pumpSizedApp(tester, home: const Scaffold(body: MiniTimerBar()));
    expect(find.byType(MiniTimerBar), findsOneWidget);
    expect(find.text('1:00'), findsNothing);
  });

  testWidgets('play then pause updates status label', (tester) async {
    await pumpSizedApp(
      tester,
      home: const Scaffold(
        body: MiniTimerBar(forceVisible: true, showOpenLink: false),
      ),
    );

    await tester.tap(find.byTooltip('Play'));
    await tester.pump();
    expect(find.text('Running'), findsOneWidget);

    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    expect(find.text('Paused'), findsOneWidget);
  });

  testWidgets('open link navigates to timer route when enabled', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              const Scaffold(body: MiniTimerBar(forceVisible: true)),
        ),
        GoRoute(
          path: '/timer',
          builder: (context, state) => const Scaffold(body: Text('Full timer')),
        ),
      ],
    );

    await tester.pumpWidget(ProviderScopeApp(router: router));
    await tester.pump();

    await tester.tap(find.text('1:00'));
    await tester.pumpAndSettle();
    expect(find.text('Full timer'), findsOneWidget);
  });
}

/// Minimal router host using the same service overrides as [pumpSizedApp].
class ProviderScopeApp extends StatelessWidget {
  const ProviderScopeApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: testServiceOverrides(),
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    );
  }
}
