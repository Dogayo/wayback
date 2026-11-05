import 'dart:async';

import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/geo_math.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

/// A point with its distance from the user; `null` until there is a fix.
typedef PointDistance = ({SavedPoint point, double? distanceMeters});

/// Points, newest first, each with its distance; a new list comes on every
/// change of the points and on every new fix.
///
/// Points depend on the location domain only, one way (architecture.md §2).
/// Without a fix the list still comes, with `null` distances.
Stream<Result<List<PointDistance>>> watchPointsWithDistance(
  PointsRepository points,
  LocationRepository location,
) {
  late final StreamController<Result<List<PointDistance>>> controller;
  StreamSubscription<Object>? pointsSubscription;
  StreamSubscription<Object>? fixSubscription;
  Result<List<SavedPoint>>? latest;
  GeoPoint? position;

  void publish() {
    switch (latest) {
      case Success(:final value):
        controller.add(
          Result.success([
            for (final point in value)
              (
                point: point,
                distanceMeters: switch (position) {
                  final here? => distanceMeters(here, point.position),
                  null => null,
                },
              ),
          ]),
        );
      case Failed(:final failure):
        controller.add(Result.failure(failure));
      case null:
        break;
    }
  }

  controller = StreamController(
    onListen: () {
      pointsSubscription = points.watchAll().listen((result) {
        latest = result;
        publish();
      });
      fixSubscription = location.watchFix().listen((result) {
        if (result case Success(:final value)) {
          position = value.point;
          publish();
        }
      });
    },
    onCancel: () async {
      await pointsSubscription?.cancel();
      await fixSubscription?.cancel();
    },
  );
  return controller.stream;
}
