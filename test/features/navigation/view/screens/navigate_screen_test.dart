import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/navigation/view/bloc/arrival_vibration_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/enable_precise_location_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_guidance_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_notice_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_stop_bloc.dart';
import 'package:wayback/features/navigation/view/screens/navigate_screen.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

import '../../../location/fake_location_repository.dart';
import '../../../points/fake_points_repository.dart';
import '../../../points/view/screens/screen_host.dart';
import '../../fake_background_navigation_repository.dart';
import '../../fake_compass_repository.dart';
import '../../fake_vibration_repository.dart';

LocationFix _fix(double southDegrees, {double accuracy = 5}) => LocationFix(
  point: GeoPoint(latitude: 55.75 - southDegrees, longitude: 37.61),
  accuracyMeters: accuracy,
  timestamp: DateTime.utc(2026, 11, 5),
);

Future<(FakeLocationRepository, FakeCompassRepository)> _pump(
  WidgetTester tester, {
  String id = 'a',
  AppSettings settings = AppSettings.defaults,
  FakeVibrationRepository? vibration,
  FakeBackgroundNavigationRepository? background,
}) async {
  final notices = background ?? FakeBackgroundNavigationRepository();
  final location = FakeLocationRepository();
  final compass = FakeCompassRepository();
  await pumpScreen(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => NavigationGuidanceBloc(
            FakePointsRepository([savedPoint('a', name: 'Машина')]),
            location,
            compass,
            pointId: id,
          )..fetch(),
        ),
        BlocProvider(create: (_) => EnablePreciseLocationBloc(location)),
        BlocProvider(
          create: (_) =>
              ArrivalVibrationBloc(vibration ?? FakeVibrationRepository()),
        ),
        BlocProvider(create: (_) => NavigationNoticeBloc(notices)),
        BlocProvider(create: (_) => NavigationStopBloc(notices)..fetch()),
      ],
      child: const NavigateScreen(),
    ),
    settings: settings,
  );
  await settle(tester);
  return (location, compass);
}

void main() {
  testWidgets('waits for GPS and compass, then shows arrow and distance', (
    tester,
  ) async {
    final (location, compass) = await _pump(tester);
    expect(find.text('Ждём GPS и компас…'), findsOneWidget);

    location.fixes.add(Result.success(_fix(0.001)));
    compass.readings.add(Result.success(heading(0)));
    await settle(tester);

    expect(find.text('Машина'), findsOneWidget);
    expect(find.byType(WbDirectionDial), findsOneWidget);
    expect(find.text('111 м'), findsOneWidget);
    expect(find.text('±5 м'), findsOneWidget);
  });

  testWidgets('warnings for an unreliable compass and a weak fix', (
    tester,
  ) async {
    final (location, compass) = await _pump(tester);
    location.fixes.add(Result.success(_fix(0.001, accuracy: 65)));
    compass.readings.add(Result.success(heading(0, accuracy: 45)));
    await settle(tester);

    expect(find.textContaining('Компас неточен'), findsOneWidget);
    expect(find.textContaining('Слабый GPS'), findsOneWidget);
  });

  Future<void> arrive(
    FakeLocationRepository location,
    FakeCompassRepository compass,
    WidgetTester tester,
  ) async {
    compass.readings.add(Result.success(heading(0)));
    location.fixes.add(Result.success(_fix(0.001)));
    await settle(tester);
    location.fixes.add(Result.success(_fix(0.00005)));
    await settle(tester);
  }

  testWidgets('the beam follows the compass accuracy', (tester) async {
    final (location, compass) = await _pump(tester);
    location.fixes.add(Result.success(_fix(0.001)));
    compass.readings.add(Result.success(heading(0, accuracy: 12)));
    await settle(tester);

    final dial = tester.widget<WbDirectionDial>(find.byType(WbDirectionDial));
    expect(dial.spread, 12);
  });

  testWidgets('warnings do not move the dial', (tester) async {
    final (location, compass) = await _pump(tester);
    location.fixes.add(Result.success(_fix(0.001)));
    compass.readings.add(Result.success(heading(0)));
    await settle(tester);
    final before = tester.getTopLeft(find.byType(WbDirectionDial));

    compass.readings.add(Result.success(heading(0, accuracy: 45)));
    await settle(tester);

    expect(find.byType(WbAlertRow), findsOneWidget);
    expect(tester.getTopLeft(find.byType(WbDirectionDial)), before);
  });

  testWidgets('arrival replaces the dial with the point and keeps a pointer', (
    tester,
  ) async {
    final (location, compass) = await _pump(tester);
    await arrive(location, compass, tester);

    final dial = tester.widget<WbArrivalDial>(find.byType(WbArrivalDial));
    expect(dial.type, WbPointType.car);
    expect(dial.rotation, isNotNull);
    expect(find.byType(WbDirectionDial), findsNothing);
  });

  testWidgets('arrival: text once and a single vibration', (tester) async {
    final vibration = FakeVibrationRepository();
    final (location, compass) = await _pump(tester, vibration: vibration);
    await arrive(location, compass, tester);

    expect(find.text('Машина где‑то рядом'), findsOneWidget);
    expect(vibration.calls, 1);
  });

  testWidgets('arrival plays the vibration the user picked', (tester) async {
    final vibration = FakeVibrationRepository();
    final (location, compass) = await _pump(
      tester,
      settings: const AppSettings(vibrationPattern: VibrationPattern.twice),
      vibration: vibration,
    );
    await arrive(location, compass, tester);

    expect(vibration.patterns, [VibrationPattern.twice]);
  });

  testWidgets('arrival with vibration turned off: text only', (tester) async {
    final vibration = FakeVibrationRepository();
    final (location, compass) = await _pump(
      tester,
      settings: const AppSettings(vibrationOnArrival: false),
      vibration: vibration,
    );
    await arrive(location, compass, tester);

    expect(find.text('Машина где‑то рядом'), findsOneWidget);
    expect(vibration.calls, 0);
  });

  testWidgets('opening inside the radius is not an arrival', (tester) async {
    final vibration = FakeVibrationRepository();
    final (location, compass) = await _pump(tester, vibration: vibration);
    compass.readings.add(Result.success(heading(0)));
    location.fixes.add(Result.success(_fix(0.00005)));
    await settle(tester);

    expect(find.text('Машина где‑то рядом'), findsOneWidget);
    expect(vibration.calls, 0);
  });

  testWidgets('GPS noise at the edge does not vibrate twice', (tester) async {
    final vibration = FakeVibrationRepository();
    final (location, compass) = await _pump(tester, vibration: vibration);
    await arrive(location, compass, tester);

    // 33 m: past the entry threshold, within the exit margin.
    location.fixes.add(Result.success(_fix(0.0003)));
    await settle(tester);
    location.fixes.add(Result.success(_fix(0.00005)));
    await settle(tester);

    expect(find.text('Машина где‑то рядом'), findsOneWidget);
    expect(vibration.calls, 1);
  });

  testWidgets('walking away and back vibrates again', (tester) async {
    final vibration = FakeVibrationRepository();
    final (location, compass) = await _pump(tester, vibration: vibration);
    await arrive(location, compass, tester);

    location.fixes.add(Result.success(_fix(0.001)));
    await settle(tester);
    expect(find.text('Машина где‑то рядом'), findsNothing);
    location.fixes.add(Result.success(_fix(0.00005)));
    await settle(tester);

    expect(vibration.calls, 2);
  });

  testWidgets('the first fix starts the notice with point and distance', (
    tester,
  ) async {
    final background = FakeBackgroundNavigationRepository();
    final (location, compass) = await _pump(tester, background: background);
    expect(background.notices, isEmpty);

    compass.readings.add(Result.success(heading(0)));
    location.fixes.add(Result.success(_fix(0.001)));
    await settle(tester);

    expect(background.notices, hasLength(1));
    expect(background.notices.single.title, 'Машина');
    expect(background.notices.single.text, '111\u00A0м');
    expect(background.notices.single.stopLabel, 'Стоп');
  });

  testWidgets('a new distance waits, arrival reaches the notice at once', (
    tester,
  ) async {
    final background = FakeBackgroundNavigationRepository();
    final (location, compass) = await _pump(tester, background: background);
    compass.readings.add(Result.success(heading(0)));
    location.fixes.add(Result.success(_fix(0.001)));
    await settle(tester);

    location.fixes.add(Result.success(_fix(0.0009)));
    await settle(tester);
    expect(background.notices, hasLength(1));

    location.fixes.add(Result.success(_fix(0.00005)));
    await settle(tester);
    expect(background.notices.last.text, 'Машина где‑то рядом');
  });

  testWidgets('leaving the screen stops the notice', (tester) async {
    final background = FakeBackgroundNavigationRepository();
    final (location, compass) = await _pump(tester, background: background);
    compass.readings.add(Result.success(heading(0)));
    location.fixes.add(Result.success(_fix(0.001)));
    await settle(tester);

    await tester.pumpWidget(const SizedBox());
    await settle(tester);

    expect(background.stops, 1);
  });

  testWidgets('imperial units: distance in feet', (tester) async {
    final (location, compass) = await _pump(
      tester,
      settings: const AppSettings(units: UnitSystem.imperial),
    );
    location.fixes.add(Result.success(_fix(0.0001)));
    compass.readings.add(Result.success(heading(0)));
    await settle(tester);

    expect(find.text('36\u00A0фт'), findsOneWidget);
    expect(find.text('±16\u00A0фт'), findsOneWidget);
  });

  testWidgets('approximate access: an error instead of the arrow', (
    tester,
  ) async {
    final (location, compass) = await _pump(tester);
    compass.readings.add(Result.success(heading(0)));
    location.fixes.add(
      const Result.failure(
        PermissionFailure(code: LocationErrorCodes.preciseRequired),
      ),
    );
    await settle(tester);

    expect(find.text('Нужна точная геолокация'), findsOneWidget);
    expect(find.byType(WbDirectionDial), findsNothing);
    expect(find.text('Машина где‑то рядом'), findsNothing);

    await tester.tap(find.text('Включить точную геолокацию'));
    await settle(tester);

    expect(location.preciseRequests, 1);
  });

  testWidgets('no compass: distance stays, the arrow goes', (tester) async {
    final (location, compass) = await _pump(tester);
    location.fixes.add(Result.success(_fix(0.001)));
    compass.readings.add(
      const Result.failure(
        SensorFailure(code: 'navigation_compass_unavailable'),
      ),
    );
    await settle(tester);

    expect(find.textContaining('Компас недоступен'), findsOneWidget);
    expect(find.byType(WbDirectionDial), findsNothing);
    expect(find.text('111 м'), findsOneWidget);
  });

  testWidgets('a missing point leads back to the list', (tester) async {
    await _pump(tester, id: 'gone');

    expect(find.text('Точка не найдена'), findsOneWidget);
    await tester.tap(find.text('К списку точек'));
    await settle(tester);
    expect(find.text('route /points'), findsOneWidget);
  });
}
