import 'package:app_di/src/dependency_collection.dart';
import 'package:app_di/src/injector.dart';

/// Owns common dependencies and an optional user-session dependency phase.
final class DependencyContainer {
  DependencyContainer({required this.commonDependencies, String? injectorName})
    : injector = Injector(injectorName) {
    commonDependencies.register(injector);
  }

  final Injector injector;
  final DependencyCollection commonDependencies;

  DependencyCollection? _userDependencies;
  bool _isDisposed = false;

  bool get hasUserDependency => _userDependencies != null;

  /// Registers one user collection for the active session.
  void initUserDependency(DependencyCollection dependencies) {
    _ensureActive();
    if (_userDependencies != null) {
      throw StateError('User dependencies have already been initialized.');
    }
    dependencies.register(injector);
    _userDependencies = dependencies;
  }

  /// Unregisters the complete user collection for the ending session.
  void disposeUserDependency() {
    _ensureActive();
    _userDependencies?.unregister(injector);
    _userDependencies = null;
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }
    _userDependencies?.unregister(injector);
    _userDependencies = null;
    commonDependencies.unregister(injector);
    injector.dispose();
    _isDisposed = true;
  }

  void _ensureActive() {
    if (_isDisposed) {
      throw StateError('DependencyContainer has been disposed.');
    }
  }
}
