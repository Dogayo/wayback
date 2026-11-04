import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/app_router.dart';
import 'package:wayback/app/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key, this.router});

  /// Overrides the router, e.g. to start a test on a specific route.
  final GoRouter? router;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = widget.router ?? createRouter();

  @override
  void dispose() {
    if (widget.router == null) {
      _router.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    onGenerateTitle: (context) => context.l10n.appTitle,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: _router,
  );
}
