import 'package:app_di/src/dependencies_scope.dart';
import 'package:app_di/src/dependency_collection.dart';
import 'package:app_di/src/injector.dart';
import 'package:flutter/widgets.dart';

/// Short, DI-specific accessors for a Flutter composition boundary.
extension DependenciesBuildContext on BuildContext {
  /// The injector exposed by the nearest [DependenciesScope].
  Injector get injector => DependenciesScope.of(this);

  /// Resolves one dependency by type and optional key.
  T di<T extends Object>({String? key}) => injector.get<T>(key: key);

  /// Resolves all dependencies registered for [T].
  List<T> diAll<T extends Object>() => injector.getAll<T>();

  /// Returns whether a dependency is registered by type and optional key.
  bool hasDi<T extends Object>({String? key}) {
    return injector.isregped<T>(key: key);
  }

  /// Installs dependencies associated with the current user session.
  void initUserDependency(DependencyCollection dependencies) {
    DependenciesScope.initUserDependency(this, dependencies);
  }

  /// Removes dependencies associated with the current user session.
  void disposeUserDependency() {
    DependenciesScope.disposeUserDependency(this);
  }
}
