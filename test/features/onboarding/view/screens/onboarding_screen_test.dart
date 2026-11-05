import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/features/onboarding/view/bloc/finish_onboarding_bloc.dart';
import 'package:wayback/features/onboarding/view/screens/onboarding_screen.dart';

import '../../../location/fake_location_repository.dart';
import '../../../points/view/screens/screen_host.dart';
import '../../fake_onboarding_repository.dart';

Future<(FakeOnboardingRepository, FakeLocationRepository)> _pump(
  WidgetTester tester, {
  FakeOnboardingRepository? onboarding,
}) async {
  final repository = onboarding ?? FakeOnboardingRepository(completed: false);
  final location = FakeLocationRepository();
  await pumpScreen(
    tester,
    BlocProvider(
      create: (_) => FinishOnboardingBloc(repository, location),
      child: const OnboardingScreen(),
    ),
  );
  await tester.pumpAndSettle();
  return (repository, location);
}

void main() {
  testWidgets('Next walks through the three steps', (tester) async {
    await _pump(tester);
    expect(find.text('Вернитесь туда, где были'), findsOneWidget);
    expect(find.bySemanticsLabel('Шаг 1 из 3'), findsOneWidget);

    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    expect(find.text('Три простых шага'), findsOneWidget);
    expect(find.text('Уходите по своим делам.'), findsOneWidget);
    expect(
      find.text('Работает без интернета. Точки хранятся только на телефоне.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    expect(find.text('Доступ к геолокации'), findsOneWidget);
    expect(find.text('Разрешить'), findsOneWidget);
    expect(find.text('Не сейчас'), findsOneWidget);
    expect(find.text('Далее'), findsNothing);
  });

  testWidgets('Skip jumps to the location step', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Пропустить'));
    await tester.pumpAndSettle();

    expect(find.text('Доступ к геолокации'), findsOneWidget);
    expect(find.bySemanticsLabel('Шаг 3 из 3'), findsOneWidget);
  });

  testWidgets('system back returns to the previous step', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Вернитесь туда, где были'), findsOneWidget);
  });

  testWidgets('Allow asks for location and leads Home', (tester) async {
    final (onboarding, location) = await _pump(tester);
    await tester.tap(find.text('Пропустить'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Разрешить'));
    await tester.pumpAndSettle();

    expect(location.requests, 1);
    expect(onboarding.completed, isTrue);
    expect(find.text('route /'), findsOneWidget);
  });

  testWidgets('Not now leads Home without asking', (tester) async {
    final (onboarding, location) = await _pump(tester);
    await tester.tap(find.text('Пропустить'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Не сейчас'));
    await tester.pumpAndSettle();

    expect(location.requests, 0);
    expect(onboarding.completed, isTrue);
    expect(find.text('route /'), findsOneWidget);
  });

  testWidgets('a failed save still leads Home', (tester) async {
    await _pump(
      tester,
      onboarding: FakeOnboardingRepository(completed: false)
        ..failNext = const StorageFailure(code: 'onboarding_storage_failed'),
    );
    await tester.tap(find.text('Пропустить'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Не сейчас'));
    await tester.pumpAndSettle();

    expect(find.text('route /'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.byType(OnboardingScreen), findsNothing);
  });
}
