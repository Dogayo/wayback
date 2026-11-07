import 'package:app_di/app_di.dart';
import 'package:app_logger/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:wayback/app/app.dart';
import 'package:wayback/app/navigation/app_router.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/navigation/domain/repositories/background_navigation_repository.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';
import 'package:wayback/features/navigation/domain/repositories/vibration_repository.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_guidance_bloc.dart';
import 'package:wayback/features/navigation/view/screens/navigate_screen.dart';
import 'package:wayback/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:wayback/features/onboarding/view/screens/onboarding_screen.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';
import 'package:wayback/features/points/view/screens/home_screen.dart';
import 'package:wayback/features/points/view/screens/point_create_screen.dart';
import 'package:wayback/features/points/view/screens/point_details_screen.dart';
import 'package:wayback/features/points/view/screens/points_list_screen.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/domain/repositories/diagnostics_repository.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';
import 'package:wayback/features/settings/view/screens/settings_screen.dart';
import 'package:wayback/features/settings/view/screens/vibration_type_screen.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

import '../../features/location/fake_location_repository.dart';
import '../../features/navigation/fake_background_navigation_repository.dart';
import '../../features/navigation/fake_compass_repository.dart';
import '../../features/navigation/fake_vibration_repository.dart';
import '../../features/onboarding/fake_onboarding_repository.dart';
import '../../features/points/fake_points_repository.dart';
import '../../features/settings/fake_diagnostics_repository.dart';
import '../../features/settings/fake_settings_repository.dart';

var _containers = 0;

Future<GoRouter> pumpApp(
  WidgetTester tester,
  String location, {
  AppSettings settings = AppSettings.defaults,
  bool onboardingCompleted = true,
  FakeBackgroundNavigationRepository? background,
}) async {
  final router = createRouter(initialLocation: location);
  addTearDown(router.dispose);
  // Denied access keeps Home static: no system dialog, no progress spinner.
  final repository = FakeLocationRepository(
    access: const Result.success(LocationAccess.denied),
  );
  final container = DependencyContainer(
    injectorName: 'router-test-${_containers++}',
    commonDependencies: DependencyList([
      RegFactory<LocationRepository>((_) => repository),
      RegFactory<PointsRepository>((_) => FakePointsRepository()),
      RegFactory<CompassRepository>((_) => FakeCompassRepository()),
      RegFactory<VibrationRepository>((_) => FakeVibrationRepository()),
      RegFactory<BackgroundNavigationRepository>(
        (_) => background ?? FakeBackgroundNavigationRepository(),
      ),
      RegFactory<AppLogger>((_) => const NoopLogger()),
      RegFactory<DiagnosticsRepository>((_) => FakeDiagnosticsRepository()),
      RegFactory<OnboardingRepository>(
        (_) => FakeOnboardingRepository(completed: onboardingCompleted),
        isSingleton: true,
      ),
      RegFactory<SettingsRepository>(
        (_) => FakeSettingsRepository(settings),
        isSingleton: true,
      ),
    ]),
  );
  await tester.pumpWidget(
    DependenciesScope(
      container: container,
      child: App(router: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  final routes = <String, Type>{
    Routes.home: HomeScreen,
    Routes.pointCreate: PointCreateScreen,
    Routes.pointsList: PointsListScreen,
    Routes.pointDetails('42'): PointDetailsScreen,
    Routes.navigate('42'): NavigateScreen,
    Routes.settings: SettingsScreen,
    Routes.vibrationType: VibrationTypeScreen,
  };

  for (final MapEntry(key: location, value: screen) in routes.entries) {
    testWidgets('$location opens $screen', (tester) async {
      await pumpApp(tester, location);
      expect(find.byType(screen), findsOneWidget);
    });
  }

  testWidgets('/points/new is not parsed as a point id', (tester) async {
    await pumpApp(tester, Routes.pointCreate);
    expect(find.byType(PointDetailsScreen), findsNothing);
  });

  testWidgets('back from a deep-linked point leads Home', (tester) async {
    await pumpApp(tester, Routes.pointDetails('42'));
    await tester.tap(find.byType(WbBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('point id reaches the navigation bloc', (tester) async {
    await pumpApp(tester, Routes.navigate('abc'));
    final bloc = tester
        .element(find.byType(NavigateScreen))
        .read<NavigationGuidanceBloc>();
    expect(bloc.pointId, 'abc');
  });

  testWidgets('Stop on the notice closes navigation', (tester) async {
    final background = FakeBackgroundNavigationRepository();
    await pumpApp(tester, Routes.navigate('abc'), background: background);

    background.stopRequests.add(const Result.success(null));
    await tester.pumpAndSettle();

    expect(find.byType(NavigateScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('the saved language applies to the whole app', (tester) async {
    await pumpApp(
      tester,
      Routes.settings,
      settings: const AppSettings(language: AppLanguage.en),
    );
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.text('Настройки'), findsOneWidget);
  });

  testWidgets('a first launch opens onboarding from any route', (tester) async {
    await pumpApp(tester, Routes.pointsList, onboardingCompleted: false);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('onboarding is not reachable once done', (tester) async {
    await pumpApp(tester, Routes.onboarding);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('finishing onboarding leads Home', (tester) async {
    await pumpApp(tester, Routes.home, onboardingCompleted: false);
    // The test window's system language is English.
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
