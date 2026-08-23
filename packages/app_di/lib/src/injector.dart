import 'dart:collection';

/// Creates a dependency using other values from [Injector].
typedef DependencyFactory<T extends Object> = T Function(Injector injector);

/// Base class for errors raised by [Injector].
sealed class InjectorException implements Exception {
  const InjectorException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a requested binding is absent.
final class DependencyNotRegisteredException extends InjectorException {
  const DependencyNotRegisteredException(super.message);
}

/// Thrown when an existing binding cannot be reassigned.
final class DependencyAlreadyRegisteredException extends InjectorException {
  const DependencyAlreadyRegisteredException(super.message);
}

/// Thrown when an injector is used after [Injector.dispose].
final class InjectorDisposedException extends InjectorException {
  const InjectorDisposedException(super.message);
}

/// A named service locator.
///
/// Calling [Injector.new] repeatedly with the same name returns the same
/// container. The unnamed container is stored separately from named ones.
final class Injector {
  factory Injector([String? name]) {
    return _injectors.putIfAbsent(name, () => Injector._(name));
  }

  Injector._(this.name);

  static final Map<String?, Injector> _injectors = <String?, Injector>{};

  final String? name;
  final Map<Type, LinkedHashMap<String?, _Registration<Object>>> _bindings =
      <Type, LinkedHashMap<String?, _Registration<Object>>>{};

  bool _isDisposed = false;

  /// Whether this container has been disposed.
  bool get isDisposed => _isDisposed;

  /// Registers a lazy factory. By default it creates a value for every get.
  void reg<T extends Object>(
    DependencyFactory<T> factory, {
    String? key,
    bool isSingleton = false,
    bool allowFutureReassignment = false,
  }) {
    _ensureActive();
    _put<T>(
      key,
      _FactoryRegistration<T>(
        factory,
        isSingleton: isSingleton,
        allowFutureReassignment: allowFutureReassignment,
      ),
    );
  }

  /// Resolves a binding by type and optional key.
  T get<T extends Object>({String? key}) {
    _ensureActive();
    final registration = _bindings[T]?[key];
    if (registration == null) {
      throw DependencyNotRegisteredException(
        'No binding for $T with key ${_displayKey(key)} in '
        '${_displayInjectorName(name)}.',
      );
    }
    return registration.resolve(this) as T;
  }

  /// Resolves every binding of [T] in registration order, regardless of key.
  List<T> getAll<T extends Object>() {
    _ensureActive();
    final registrations = _bindings[T];
    if (registrations == null) {
      return <T>[];
    }
    return registrations.values
        .map((registration) => registration.resolve(this) as T)
        .toList(growable: false);
  }

  /// Returns whether a binding exists for [T] and [key].
  bool isregped<T extends Object>({String? key}) {
    _ensureActive();
    return _bindings[T]?.containsKey(key) ?? false;
  }

  /// Removes one binding and its cached singleton, if any.
  bool removeregping<T extends Object>({String? key}) {
    _ensureActive();
    final registrations = _bindings[T];
    if (registrations == null) {
      return false;
    }
    final removed = registrations.remove(key) != null;
    if (registrations.isEmpty) {
      _bindings.remove(T);
    }
    return removed;
  }

  /// Removes all bindings for [T] and returns how many were removed.
  int removeAllregpings<T extends Object>() {
    _ensureActive();
    return _bindings.remove(T)?.length ?? 0;
  }

  /// Clears all bindings and removes this container from the global registry.
  void dispose() {
    if (_isDisposed) {
      return;
    }
    _bindings.clear();
    _isDisposed = true;
    if (identical(_injectors[name], this)) {
      _injectors.remove(name);
    }
  }

  void _put<T extends Object>(String? key, _Registration<T> registration) {
    final registrations = _bindings.putIfAbsent(
      T,
      () => LinkedHashMap<String?, _Registration<Object>>(),
    );
    final existing = registrations[key];
    if (existing != null && !existing.allowFutureReassignment) {
      throw DependencyAlreadyRegisteredException(
        'Binding for $T with key ${_displayKey(key)} already exists in '
        '${_displayInjectorName(name)}.',
      );
    }
    registrations[key] = registration;
  }

  void _ensureActive() {
    if (_isDisposed) {
      throw InjectorDisposedException(
        '${_displayInjectorName(name)} has been disposed.',
      );
    }
  }

  static String _displayKey(String? key) =>
      key == null ? '<default>' : '"$key"';

  static String _displayInjectorName(String? name) {
    return name == null ? 'the default injector' : 'injector "$name"';
  }
}

sealed class _Registration<T extends Object> {
  const _Registration({required this.allowFutureReassignment});

  final bool allowFutureReassignment;

  T resolve(Injector injector);
}

final class _FactoryRegistration<T extends Object> extends _Registration<T> {
  _FactoryRegistration(
    this.factory, {
    required this.isSingleton,
    required super.allowFutureReassignment,
  });

  final DependencyFactory<T> factory;
  final bool isSingleton;

  late T _instance;
  bool _hasInstance = false;

  @override
  T resolve(Injector injector) {
    if (!isSingleton) {
      return factory(injector);
    }
    if (!_hasInstance) {
      _instance = factory(injector);
      _hasInstance = true;
    }
    return _instance;
  }
}
