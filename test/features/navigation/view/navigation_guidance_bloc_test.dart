import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_guidance.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_guidance_bloc.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

import '../../location/fake_location_repository.dart';
import '../../points/fake_points_repository.dart';
import '../fake_compass_repository.dart';

/// The user, due south of the point by about 111 m per 0.001°.
LocationFix _fixSouth(double degrees, {double accuracy = 5}) => LocationFix(
  point: GeoPoint(latitude: 55.75 - degrees, longitude: 37.61),
  accuracyMeters: accuracy,
  timestamp: DateTime.utc(2026, 11, 5),
);

void main() {
  late FakeLocationRepository location;
  late FakeCompassRepository compass;
  late NavigationGuidanceBloc bloc;

  Future<void> start({String id = 'a'}) async {
    bloc = NavigationGuidanceBloc(
      FakePointsRepository([savedPoint('a', name: 'Машина')]),
      location,
      compass,
      pointId: id,
    )..fetch();
    addTearDown(bloc.close);
    await pumpEventQueue();
  }

  NavigationGuidance guidance() => bloc.state.dataOrNull!;

  setUp(() {
    location = FakeLocationRepository();
    compass = FakeCompassRepository();
  });

  test('distance and arrow toward the point', () async {
    await start();
    location.fixes.add(Result.success(_fixSouth(0.001)));
    compass.readings.add(Result.success(heading(0)));
    await pumpEventQueue();

    expect(guidance().distanceMeters, closeTo(111, 1));
    expect(guidance().arrowDegrees, closeTo(0, 0.01));
    expect(guidance().compass, CompassStatus.ok);
    expect(guidance().arrived, isFalse);
  });

  test('the arrow turns the short way across north', () async {
    await start();
    location.fixes.add(Result.success(_fixSouth(0.001)));
    compass.readings.add(Result.success(heading(2)));
    await pumpEventQueue();
    expect(guidance().arrowDegrees, closeTo(358, 0.01));

    compass.readings.add(Result.success(heading(358)));
    await pumpEventQueue();
    expect(guidance().arrowDegrees, closeTo(362, 0.01));
  });

  test('arrival inside the radius', () async {
    await start();
    location.fixes.add(Result.success(_fixSouth(0.0001)));
    await pumpEventQueue();

    expect(guidance().arrived, isTrue);
  });

  test('an unreliable compass keeps the arrow and warns', () async {
    await start();
    location.fixes.add(Result.success(_fixSouth(0.001)));
    compass.readings.add(Result.success(heading(0, accuracy: 45)));
    await pumpEventQueue();

    expect(guidance().compass, CompassStatus.unreliable);
    expect(guidance().arrowDegrees, isNotNull);
  });

  test('no compass: distance only', () async {
    await start();
    location.fixes.add(Result.success(_fixSouth(0.001)));
    compass.readings.add(
      const Result.failure(
        SensorFailure(code: NavigationErrorCodes.compassUnavailable),
      ),
    );
    await pumpEventQueue();

    expect(guidance().compass, CompassStatus.unavailable);
    expect(guidance().arrowDegrees, isNull);
    expect(guidance().distanceMeters, closeTo(111, 1));
  });

  test('a weak fix is flagged', () async {
    await start();
    location.fixes.add(Result.success(_fixSouth(0.001, accuracy: 65)));
    await pumpEventQueue();

    expect(guidance().weakSignal, isTrue);
  });

  test('a missing point is not found', () async {
    await start(id: 'gone');
    expect(
      bloc.state.mapOrNull(failure: (s) => s.failure.code),
      PointsErrorCodes.notFound,
    );
  });

  test('a lost fix is a failure', () async {
    await start();
    location.fixes.add(
      const Result.failure(SensorFailure(code: 'location_unavailable')),
    );
    await pumpEventQueue();

    expect(bloc.state, isA<DataFailure<NavigationGuidance>>());
  });

  test('closing the bloc stops GPS and compass', () async {
    await start();
    expect(compass.isListened, isTrue);
    expect(location.fixes.hasListener, isTrue);

    await bloc.close();

    expect(compass.isListened, isFalse);
    expect(location.fixes.hasListener, isFalse);
  });
}
