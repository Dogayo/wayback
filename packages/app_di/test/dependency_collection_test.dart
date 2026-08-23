import 'package:app_di/app_di.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('collection registers and unregisters a batch', () {
    final injector = Injector('collection-test');
    final collection = DependencyList(<RegType>[
      RegFactory<_Value>((_) => const _Value(1)),
      RegFactory<_Value>((_) => const _Value(2), key: 'other'),
    ]);

    collection.register(injector);
    expect(injector.getAll<_Value>(), hasLength(2));

    collection.unregister(injector);
    expect(injector.getAll<_Value>(), isEmpty);
    injector.dispose();
  });

  test('container keeps common bindings while replacing a user phase', () {
    final common = DependencyList(<RegType>[
      RegFactory<_Common>((_) => const _Common()),
    ]);
    final user = DependencyList(<RegType>[
      RegFactory<_User>((_) => const _User()),
    ]);
    final container = DependencyContainer(
      commonDependencies: common,
      injectorName: 'two-phase-test',
    );

    expect(container.injector.isregped<_Common>(), isTrue);
    expect(container.injector.isregped<_User>(), isFalse);

    container.initUserDependency(user);
    expect(container.injector.isregped<_User>(), isTrue);

    container.disposeUserDependency();
    expect(container.injector.isregped<_Common>(), isTrue);
    expect(container.injector.isregped<_User>(), isFalse);

    container.dispose();
  });

  test('collection rolls back registrations when a module fails', () {
    final injector = Injector('rollback-test');
    injector.reg<_User>((_) => const _User());
    final collection = DependencyList(<RegType>[
      RegFactory<_Common>((_) => const _Common()),
      RegFactory<_User>((_) => const _User()),
    ]);

    expect(
      () => collection.register(injector),
      throwsA(isA<DependencyAlreadyRegisteredException>()),
    );
    expect(injector.isregped<_Common>(), isFalse);
    expect(injector.isregped<_User>(), isTrue);

    injector.dispose();
  });
}

final class _Value {
  const _Value(this.id);

  final int id;
}

final class _Common {
  const _Common();
}

final class _User {
  const _User();
}
