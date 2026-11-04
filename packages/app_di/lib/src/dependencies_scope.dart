import 'package:app_di/src/dependency_collection.dart';
import 'package:app_di/src/dependency_container.dart';
import 'package:app_di/src/injector.dart';
import 'package:flutter/widgets.dart';

/// Exposes an [Injector] to a Flutter subtree and owns its lifecycle.
final class DependenciesScope extends StatefulWidget {
  const DependenciesScope({
    required this.container,
    required this.child,
    super.key,
  });

  /// A container created during application bootstrap, before `runApp`.
  final DependencyContainer container;
  final Widget child;

  /// Returns the injector associated with the nearest scope.
  static Injector of(BuildContext context) {
    return _scopeOf(context).container.injector;
  }

  /// Installs the dependencies associated with the current user session.
  static void initUserDependency(
    BuildContext context,
    DependencyCollection dependencies,
  ) {
    _scopeOf(context).container.initUserDependency(dependencies);
  }

  /// Removes every dependency associated with the current user session.
  static void disposeUserDependency(BuildContext context) {
    _scopeOf(context).container.disposeUserDependency();
  }

  static _DependenciesInherited _scopeOf(BuildContext context) {
    // Lookup without a dependency: the container is created once in bootstrap
    // and never swapped, and a dependency would forbid reads from initState
    // or a BlocProvider's create.
    final scope = context
        .getInheritedWidgetOfExactType<_DependenciesInherited>();
    if (scope == null) {
      throw FlutterError(
        'DependenciesScope.of() called with a context that does not contain '
        'a DependenciesScope.',
      );
    }
    return scope;
  }

  @override
  State<DependenciesScope> createState() => _DependenciesScopeState();
}

final class _DependenciesScopeState extends State<DependenciesScope> {
  late DependencyContainer _container;

  @override
  void initState() {
    super.initState();
    _container = widget.container;
  }

  @override
  void didUpdateWidget(DependenciesScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.container, oldWidget.container)) {
      _container.dispose();
      _container = widget.container;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DependenciesInherited(container: _container, child: widget.child);
  }

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }
}

final class _DependenciesInherited extends InheritedWidget {
  const _DependenciesInherited({required this.container, required super.child});

  final DependencyContainer container;

  @override
  bool updateShouldNotify(_DependenciesInherited oldWidget) {
    return !identical(container, oldWidget.container);
  }
}
