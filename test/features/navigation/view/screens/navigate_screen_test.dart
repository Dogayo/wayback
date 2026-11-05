import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/app/settings/settings_scope.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_guidance_bloc.dart';
import 'package:wayback/features/navigation/view/screens/navigate_screen.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

import '../../../location/fake_location_repository.dart';
import '../../../points/fake_points_repository.dart';
import '../../../points/view/screens/screen_host.dart';
import '../../fake_compass_repository.dart';

LocationFix _fix(double southDegrees, {double accuracy = 5}) => LocationFix(
  point: GeoPoint(latitude: 55.75 - southDegrees, longitude: 37.61),
  accuracyMeters: accuracy,
  timestamp: DateTime.utc(2026, 11, 5),
);

Future<(FakeLocationRepository, FakeCompassRepository)> _pump(
  WidgetTester tester, {
  String id = 'a',
  AppSettings settings = AppSettings.defaults,
}) async {
  final location = FakeLocationRepository();
  final compass = FakeCompassRepository();
  await pumpScreen(
    tester,
    BlocProvider(
      create: (_) => NavigationGuidanceBloc(
        FakePointsRepository([savedPoint('a', name: 'Машина')]),
        location,
        compass,
        pointId: id,
      )..fetch(),
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
    expect(find.byType(WbCompassArrow), findsOneWidget);
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

    expect(find.text('Компас неточен'), findsOneWidget);
    expect(find.text('Слабый сигнал GPS'), findsOneWidget);
  });

  List<String> recordHaptics(WidgetTester tester) {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add('${call.arguments}');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    return haptics;
  }

  Future<void> arrive(
    FakeLocationRepository location,
    FakeCompassRepository compass,
    WidgetTester tester,
  ) async {
    compass.readings.add(Result.success(heading(0)));
    location.fixes.add(Result.success(_fix(0.0001)));
    await settle(tester);
    location.fixes.add(Result.success(_fix(0.00005)));
    await settle(tester);
  }

  testWidgets('arrival: text once and a single vibration', (tester) async {
    final haptics = recordHaptics(tester);
    final (location, compass) = await _pump(tester);
    await arrive(location, compass, tester);

    expect(find.text('Вы на месте'), findsOneWidget);
    expect(haptics, ['HapticFeedbackType.mediumImpact']);
  });

  testWidgets('arrival with vibration turned off: text only', (tester) async {
    final haptics = recordHaptics(tester);
    final (location, compass) = await _pump(
      tester,
      settings: const AppSettings(vibrationOnArrival: false),
    );
    await arrive(location, compass, tester);

    expect(find.text('Вы на месте'), findsOneWidget);
    expect(haptics, isEmpty);
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

  testWidgets('no compass: distance stays, the arrow goes', (tester) async {
    final (location, compass) = await _pump(tester);
    location.fixes.add(Result.success(_fix(0.001)));
    compass.readings.add(
      const Result.failure(
        SensorFailure(code: 'navigation_compass_unavailable'),
      ),
    );
    await settle(tester);

    expect(find.text('Компас недоступен'), findsOneWidget);
    expect(find.byType(WbCompassArrow), findsNothing);
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
