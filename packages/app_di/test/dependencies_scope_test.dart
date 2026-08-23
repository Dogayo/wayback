import 'package:app_di/app_di.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('scope exposes injector and controls user dependencies', (
    tester,
  ) async {
    final common = DependencyList(<RegType>[
      RegFactory<_Common>((_) => const _Common()),
    ]);
    final user = DependencyList(<RegType>[
      RegFactory<_User>((_) => const _User()),
    ]);
    final container = DependencyContainer(
      commonDependencies: common,
      injectorName: 'widget-test',
    );
    Injector? scopedInjector;
    _Common? commonDependency;
    List<_Common>? allCommonDependencies;
    bool? hasCommonDependency;

    await tester.pumpWidget(
      DependenciesScope(
        container: container,
        child: Builder(
          builder: (context) {
            scopedInjector = context.injector;
            commonDependency = context.di<_Common>();
            allCommonDependencies = context.diAll<_Common>();
            hasCommonDependency = context.hasDi<_Common>();
            return const SizedBox();
          },
        ),
      ),
    );

    expect(scopedInjector!.isregped<_Common>(), isTrue);
    expect(commonDependency, isA<_Common>());
    expect(allCommonDependencies, hasLength(1));
    expect(hasCommonDependency, isTrue);

    final context = tester.element(find.byType(SizedBox));
    context.initUserDependency(user);
    expect(scopedInjector!.isregped<_User>(), isTrue);

    context.disposeUserDependency();
    expect(scopedInjector!.isregped<_User>(), isFalse);

    await tester.pumpWidget(const SizedBox());
    expect(scopedInjector!.isDisposed, isTrue);
  });
}

final class _Common {
  const _Common();
}

final class _User {
  const _User();
}
