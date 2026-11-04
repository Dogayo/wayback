import 'package:app_di/app_di.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:wayback/app/app.dart';
import 'package:wayback/app/navigation/app_router.dart';
import 'package:wayback/app/navigation/routes.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/navigation/view/screens/navigate_screen.dart';
import 'package:wayback/features/points/view/screens/home_screen.dart';
import 'package:wayback/features/points/view/screens/point_create_screen.dart';
import 'package:wayback/features/points/view/screens/point_details_screen.dart';
import 'package:wayback/features/points/view/screens/points_list_screen.dart';
import 'package:wayback/features/settings/view/screens/settings_screen.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

import '../../features/location/fake_location_repository.dart';

var _containers = 0;

Future<GoRouter> pumpApp(WidgetTester tester, String location) async {
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

  testWidgets('point id reaches the screen', (tester) async {
    await pumpApp(tester, Routes.navigate('abc'));
    final screen = tester.widget<NavigateScreen>(find.byType(NavigateScreen));
    expect(screen.pointId, 'abc');
  });
}
