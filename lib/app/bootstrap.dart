import 'package:app_di/app_di.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wayback/app/app.dart';
import 'package:wayback/app/dependencies/app_dependencies.dart';

/// Initialization order: architecture.md §5.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();

  final dependencies = DependencyContainer(
    commonDependencies: AppDependencies(preferences: preferences),
  );

  runApp(DependenciesScope(container: dependencies, child: const App()));
}
