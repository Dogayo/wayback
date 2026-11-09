import 'dart:async';

import 'package:app_di/app_di.dart';
import 'package:app_logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:wayback/app/feedback/action_result_listener.dart';
import 'package:wayback/app/haptics/app_haptics.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/navigation/app_router.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/app/theme/app_theme.dart';
import 'package:wayback/features/navigation/domain/repositories/vibration_repository.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';
import 'package:wayback/features/points/view/bloc/restore_point_bloc.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';
import 'package:wayback/features/settings/view/bloc/settings_bloc.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

class App extends StatefulWidget {
  const App({super.key, this.router});

  /// Overrides the router, e.g. to start a test on a specific route.
  final GoRouter? router;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = widget.router ?? createRouter();
  late final AppLogger _logger;
  late final AppLifecycleListener _lifecycle;
  late final AppHaptics _haptics;
  String? _route;

  @override
  void initState() {
    super.initState();
    _logger = context.di<AppLogger>();
    _haptics = AppHaptics(context.di<VibrationRepository>());
    _lifecycle = AppLifecycleListener(
      onResume: () => _logger.info('app', 'resumed'),
      // The system may kill the app from here on: nothing stays buffered.
      onPause: () {
        _logger.info('app', 'paused');
        unawaited(_logger.flush());
      },
    );
    _router.routerDelegate.addListener(_logRoute);
  }

  void _logRoute() {
    final route = _router.routerDelegate.currentConfiguration.uri.path;
    if (route == _route) return;
    _route = route;
    _logger.info('route', route);
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_logRoute);
    _lifecycle.dispose();
    if (widget.router == null) {
      _router.dispose();
    }
    super.dispose();
  }

  /// Settings apply app-wide: [SettingsBloc] sits above every route, and
  /// [SettingsScope] hands the current values to screens.
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        lazy: false,
        create: (context) =>
            SettingsBloc(context.di<SettingsRepository>())..fetch(),
      ),
      BlocProvider(
        create: (context) => RestorePointBloc(context.di<PointsRepository>()),
      ),
    ],
    child: BlocBuilder<SettingsBloc, DataState<AppSettings>>(
      builder: (context, state) {
        final settings = state.dataOrNull ?? AppSettings.defaults;
        _haptics.enabled = settings.touchFeedback;
        return SettingsScope(
          settings: settings,
          child: MaterialApp.router(
            onGenerateTitle: (context) => context.l10n.appTitle,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            locale: settings.language.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: _router,
            builder: (context, child) => WbHapticsScope(
              player: _haptics.play,
              child: ActionResultListener<RestorePointBloc, SavedPoint>(
                successHaptic: null,
                child: child,
              ),
            ),
          ),
        );
      },
    ),
  );
}
