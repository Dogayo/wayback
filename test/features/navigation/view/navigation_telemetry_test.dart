import 'dart:io';

import 'package:app_logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_guidance_bloc.dart';

import '../../location/fake_location_repository.dart';
import '../../points/fake_points_repository.dart';
import '../fake_compass_repository.dart';

LocationFix _fixSouth(double degrees) => LocationFix(
  point: GeoPoint(latitude: 55.75 - degrees, longitude: 37.61),
  accuracyMeters: 5,
  timestamp: DateTime.utc(2026, 11, 5),
);

void main() {
  late Directory directory;
  late FileLogger logger;
  late FakeLocationRepository location;
  late FakeCompassRepository compass;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('telemetry_test');
    logger = FileLogger(directory: directory);
    location = FakeLocationRepository();
    compass = FakeCompassRepository();
    final bloc = NavigationGuidanceBloc(
      FakePointsRepository([savedPoint('a', name: 'Секретная дача')]),
      location,
      compass,
      pointId: 'a',
      logger: logger,
    )..fetch();
    addTearDown(bloc.close);
    await pumpEventQueue();
  });

  tearDown(() => directory.delete(recursive: true));

  Future<String> localLog() async {
    await logger.flush();
    final files = (await directory.list().toList()).whereType<File>();
    return files.single.readAsString();
  }

  test('samples at most once a second, with coordinates locally', () async {
    compass.readings.add(Result.success(heading(0)));
    for (var i = 0; i < 5; i++) {
      location.fixes.add(Result.success(_fixSouth(0.001)));
      await pumpEventQueue();
    }

    final log = await localLog();
    expect('"msg":"sample"'.allMatches(log), hasLength(1));
    expect(log, contains('"accuracy":5.0'));
    expect(log, contains('"heading":0.0'));
    expect(log, contains('"lat":55.749'));
  });

  test('arrival is logged the moment it changes', () async {
    compass.readings.add(Result.success(heading(0)));
    location.fixes.add(Result.success(_fixSouth(0.001)));
    await pumpEventQueue();
    location.fixes.add(Result.success(_fixSouth(0.00005)));
    await pumpEventQueue();

    expect(await localLog(), contains('"msg":"arrived","f":{"from":false'));
  });

  test('the shared log has no coordinates and no point name', () async {
    compass.readings.add(Result.success(heading(0)));
    location.fixes.add(Result.success(_fixSouth(0.001)));
    await pumpEventQueue();

    final shared = await (await logger.exportShareable())!.readAsString();

    expect(shared, contains('"msg":"sample"'));
    expect(shared, isNot(contains('55.74')));
    expect(shared, isNot(contains('37.61')));
    expect(shared, isNot(contains('Секретная дача')));
  });
}
