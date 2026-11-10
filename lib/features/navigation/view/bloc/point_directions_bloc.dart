import 'dart:async';

import 'package:wayback/core/bloc/data/data_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/geo_math.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/navigation/domain/entities/compass_reading.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_guidance.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

export 'package:wayback/core/bloc/data/data_bloc.dart';
export 'package:wayback/features/navigation/domain/entities/navigation_guidance.dart'
    show CompassStatus;

/// Arrows to the active points for one moment.
final class PointDirections {
  const PointDirections({
    required this.arrows,
    required this.compass,
    this.compassAccuracyDegrees,
  });

  /// Arrow rotation by point id, degrees, not wrapped; empty while there is
  /// no direction.
  final Map<String, double> arrows;
  final CompassStatus compass;

  /// How far the heading can be off; `null` when the sensor does not say.
  final double? compassAccuracyDegrees;
}

/// Direction to every active point, for the preview on Home (SCREENS.md §4.1).
///
/// Closing with the screen is not enough here: Home stays alive under other
/// routes, so `PointDirectionsGate` starts and stops this bloc.
final class PointDirectionsBloc extends DataBloc<PointDirections> {
  PointDirectionsBloc(this._points, this._location, this._compass);

  final PointsRepository _points;
  final LocationRepository _location;
  final CompassRepository _compass;

  // Survives stop and refresh, so arrows do not spin round on return.
  final _arrows = <String, double>{};

  @override
  Stream<Result<PointDirections>> watch() {
    late final StreamController<Result<PointDirections>> controller;
    final subscriptions = <StreamSubscription<Object>>[];
    var points = const <SavedPoint>[];
    GeoPoint? position;
    Result<CompassReading>? compass;

    void publish() {
      final here = position;
      final status = switch (compass) {
        Success(value: final reading) when reading.isUnreliable =>
          CompassStatus.unreliable,
        Success() => CompassStatus.ok,
        Failed() => CompassStatus.unavailable,
        null => CompassStatus.ok,
      };
      final arrows = <String, double>{};
      if (compass case Success(value: final reading) when here != null) {
        for (final point in points) {
          if (!point.isActive) continue;
          final target = arrowRotationDegrees(
            bearingDegrees: bearingDegrees(here, point.position),
            headingDegrees: reading.headingDegrees,
          );
          arrows[point.id] = switch (_arrows[point.id]) {
            final previous? => continuousRotationDegrees(previous, target),
            null => target,
          };
        }
        _arrows
          ..clear()
          ..addAll(arrows);
      }
      controller.add(
        Result.success(
          PointDirections(
            arrows: arrows,
            compass: status,
            compassAccuracyDegrees: switch (compass) {
              Success(value: final reading) => reading.accuracyDegrees,
              _ => null,
            },
          ),
        ),
      );
    }

    controller = StreamController(
      onListen: () {
        subscriptions
          ..add(
            _points.watchAll().listen((result) {
              if (result case Success(:final value)) {
                points = value;
                publish();
              }
            }),
          )
          ..add(
            _location.watchFix().listen((result) {
              if (result case Success(:final value)) {
                position = value.point;
                publish();
              }
            }),
          )
          ..add(
            _compass.watchHeading().listen((result) {
              compass = result;
              publish();
            }),
          );
      },
      onCancel: () async {
        await Future.wait([
          for (final subscription in subscriptions) subscription.cancel(),
        ]);
      },
    );
    return controller.stream;
  }
}
