import 'package:app_di/app_di.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Injector injector;

  setUp(() {
    injector = Injector('injector-test');
  });

  tearDown(() {
    injector.dispose();
  });

  test('named injectors share a global entry by name', () {
    expect(Injector('injector-test'), same(injector));
    expect(Injector('another-test'), isNot(same(injector)));
    Injector('another-test').dispose();
  });

  test('dispose removes the injector from the global registry', () {
    injector.dispose();

    final replacement = Injector('injector-test');
    expect(replacement, isNot(same(injector)));
    replacement.dispose();
  });

  test('factory is lazy and transient by default', () {
    var calls = 0;
    injector.reg<_Value>((_) => _Value(++calls));

    expect(calls, 0);
    expect(injector.get<_Value>().id, 1);
    expect(injector.get<_Value>().id, 2);
  });

  test('singleton is created lazily and cached', () {
    var calls = 0;
    injector.reg<_Value>((_) => _Value(++calls), isSingleton: true);

    final first = injector.get<_Value>();
    final second = injector.get<_Value>();

    expect(first, same(second));
    expect(calls, 1);
  });

  test('factory can resolve its dependency graph', () {
    injector.reg<_Value>((_) => const _Value(7));
    injector.reg<_Consumer>((i) => _Consumer(i.get<_Value>()));

    expect(injector.get<_Consumer>().value.id, 7);
  });

  test('keys distinguish bindings and getAll preserves registration order', () {
    injector
      ..reg<_Value>((_) => const _Value(1))
      ..reg<_Value>((_) => const _Value(2), key: 'second');

    expect(injector.get<_Value>().id, 1);
    expect(injector.get<_Value>(key: 'second').id, 2);
    expect(
      injector.getAll<_Value>().map((value) => value.id),
      orderedEquals(<int>[1, 2]),
    );
  });

  test('registration checks and removals include keys', () {
    injector
      ..reg<_Value>((_) => const _Value(1))
      ..reg<_Value>((_) => const _Value(2), key: 'other');

    expect(injector.isregped<_Value>(), isTrue);
    expect(injector.removeregping<_Value>(), isTrue);
    expect(injector.isregped<_Value>(), isFalse);
    expect(injector.removeAllregpings<_Value>(), 1);
    expect(injector.isregped<_Value>(key: 'other'), isFalse);
  });

  test('duplicate throws unless the old binding permits reassignment', () {
    injector.reg<_Value>((_) => const _Value(1));

    expect(
      () => injector.reg<_Value>((_) => const _Value(2)),
      throwsA(isA<DependencyAlreadyRegisteredException>()),
    );

    injector
      ..removeregping<_Value>()
      ..reg<_Value>((_) => const _Value(1), allowFutureReassignment: true)
      ..reg<_Value>((_) => const _Value(2));

    expect(injector.get<_Value>().id, 2);
  });

  test('missing and disposed injectors produce specific errors', () {
    expect(
      injector.get<_Value>,
      throwsA(isA<DependencyNotRegisteredException>()),
    );

    injector.dispose();
    expect(
      () => injector.reg<_Value>((_) => const _Value(1)),
      throwsA(isA<InjectorDisposedException>()),
    );
  });
}

final class _Value {
  const _Value(this.id);

  final int id;
}

final class _Consumer {
  const _Consumer(this.value);

  final _Value value;
}
