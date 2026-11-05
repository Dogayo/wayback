import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Pumps [screen] at `/screen` in a router whose other routes only print
/// where navigation went, e.g. `route /points/a`. [settings] are what the
/// app would hand down from the settings screen.
Future<GoRouter> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  AppSettings settings = AppSettings.defaults,
}) async {
  // A phone-sized window, so lazily built lists show whole screens.
  tester.view
    ..physicalSize = const Size(1080, 3000)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  Widget page(GoRouterState state) =>
      Scaffold(body: Text('route ${state.uri.path}'));
  final router = GoRouter(
    initialLocation: '/screen',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, state) => page(state),
        routes: [
          GoRoute(path: 'screen', builder: (_, _) => screen),
          for (final path in [
            'points',
            'points/new',
            'points/:id',
            'navigate/:id',
            'settings',
          ])
            GoRoute(path: path, builder: (_, state) => page(state)),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      theme: WbTheme.light,
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (_, child) => SettingsScope(settings: settings, child: child!),
    ),
  );
  await tester.pump();
  return router;
}

/// Lets blocs settle without waiting for endless animations (skeletons,
/// progress indicators) to stop.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}
