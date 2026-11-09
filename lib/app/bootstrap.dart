import 'package:app_di/app_di.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wayback/app/app.dart';
import 'package:wayback/app/dependencies/app_dependencies.dart';
import 'package:wayback/app/diagnostics/app_log.dart';
import 'package:wayback/app/diagnostics/log_bloc_observer.dart';

/// Initialization order: architecture.md §5.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final logger = await openAppLog();
  logCrashes(logger);
  Bloc.observer = LogBlocObserver(logger);

  final preferences = await SharedPreferences.getInstance();

  final dependencies = DependencyContainer(
    commonDependencies: AppDependencies(
      preferences: preferences,
      logger: logger,
    ),
  );

  runApp(DependenciesScope(container: dependencies, child: const App()));
}
