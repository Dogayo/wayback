import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/view/bloc/location_fix_bloc.dart';
import 'package:wayback/features/location/view/bloc/open_location_settings_bloc.dart';
import 'package:wayback/features/location/view/bloc/request_location_permission_bloc.dart';
import 'package:wayback/features/location/view/widgets/gps_status.dart';
import 'package:wayback/features/points/view/bloc/home_bloc.dart';
import 'package:wayback/features/points/view/screens/home_screen.dart';

import '../../../location/fake_location_repository.dart';
import '../../fake_points_repository.dart';
import 'screen_host.dart';

Future<FakeLocationRepository> _pump(
  WidgetTester tester,
  FakePointsRepository points,
) async {
  final location = FakeLocationRepository(
    access: const Result.success(LocationAccess.denied),
  );
  await pumpScreen(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocationFixBloc(location)..fetch()),
        BlocProvider(create: (_) => RequestLocationPermissionBloc(location)),
        BlocProvider(create: (_) => OpenLocationSettingsBloc(location)),
        BlocProvider(create: (_) => HomeBloc(points, location)..fetch()),
      ],
      child: const HomeScreen(gpsStatus: GpsStatus()),
    ),
  );
  await settle(tester);
  return location;
}

void main() {
  testWidgets('first launch: empty state and Save', (tester) async {
    await _pump(tester, FakePointsRepository());

    expect(find.text('Пока нет точек'), findsOneWidget);
    await tester.tap(find.text('Сохранить место'));
    await settle(tester);
    expect(find.text('route /points/new'), findsOneWidget);
  });

  testWidgets('points but none active: offers to choose one', (tester) async {
    await _pump(tester, FakePointsRepository([savedPoint('a', active: false)]));

    expect(find.text('Нет активных точек'), findsOneWidget);
    await tester.tap(find.text('Выбрать точку'));
    await settle(tester);
    expect(find.text('route /points'), findsOneWidget);
  });

  testWidgets('active points with distance, a tap navigates', (tester) async {
    final location = await _pump(
      tester,
      FakePointsRepository([savedPoint('a', name: 'Машина')]),
    );
    expect(find.text('Машина'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);

    location.fixes.add(Result.success(fixWithAccuracy(8)));
    await settle(tester);
    expect(find.text('—'), findsNothing);

    await tester.tap(find.text('Машина'));
    await settle(tester);
    expect(find.text('route /navigate/a'), findsOneWidget);
  });

  testWidgets('GPS state sits above the points', (tester) async {
    await _pump(tester, FakePointsRepository());
    expect(find.text('Доступ к геолокации'), findsOneWidget);
    expect(find.byType(GpsStatus), findsOneWidget);
    expect(find.byType(Column), findsWidgets);
  });
}
