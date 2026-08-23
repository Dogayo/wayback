import 'package:app_di/src/injector.dart';

/// A declarative registration that can be applied to an [Injector].
abstract interface class RegType {
  String? get key;

  Type get dependencyType;

  void register(Injector injector);

  void unregister(Injector injector);
}

/// A declarative lazy factory registration.
final class RegFactory<T extends Object> implements RegType {
  const RegFactory(
    this.factory, {
    this.key,
    this.isSingleton = false,
    this.allowFutureReassignment = false,
  });

  final DependencyFactory<T> factory;

  @override
  final String? key;

  final bool isSingleton;
  final bool allowFutureReassignment;

  @override
  Type get dependencyType => T;

  @override
  void register(Injector injector) {
    injector.reg<T>(
      factory,
      key: key,
      isSingleton: isSingleton,
      allowFutureReassignment: allowFutureReassignment,
    );
  }

  @override
  void unregister(Injector injector) {
    injector.removeregping<T>(key: key);
  }
}

/// A group of registrations installed and removed as one unit.
abstract class DependencyCollection {
  const DependencyCollection();

  Iterable<RegType> get dependencies;

  void register(Injector injector) {
    final registered = <RegType>[];
    try {
      for (final dependency in dependencies) {
        dependency.register(injector);
        registered.add(dependency);
      }
    } on Object {
      for (final dependency in registered.reversed) {
        dependency.unregister(injector);
      }
      rethrow;
    }
  }

  void unregister(Injector injector) {
    final registrations = dependencies.toList(growable: false);
    for (final dependency in registrations.reversed) {
      dependency.unregister(injector);
    }
  }
}

/// A collection backed by an inline list.
final class DependencyList extends DependencyCollection {
  const DependencyList(this.dependencies);

  @override
  final List<RegType> dependencies;
}
