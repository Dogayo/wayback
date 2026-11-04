import 'package:app_di/app_di.dart';
import 'package:flutter/widgets.dart';

import 'package:wayback/app/app.dart';
import 'package:wayback/app/dependencies/app_dependencies.dart';

/// Initialization order: architecture.md §5.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Async dependencies (local storage, etc.) are initialized here, before
  // the container is built.

  final dependencies = DependencyContainer(
    commonDependencies: const AppDependencies(),
  );

  runApp(DependenciesScope(container: dependencies, child: const App()));
}
