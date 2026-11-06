import 'dart:async';

import 'package:app_logger/app_logger.dart';
import 'package:wayback/core/bloc/data/data_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/arrival.dart';
import 'package:wayback/core/utils/geo/geo_math.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/navigation/domain/entities/compass_reading.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_guidance.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';
import 'package:wayback/features/navigation/view/bloc/navigation_telemetry.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

export 'package:wayback/core/bloc/data/data_bloc.dart';

/// Direction and distance to one point, updated with every fix and compass
/// reading (mvp-scope.md §2.3, §2.4).
///
/// Navigation depends on the points and location domains, one way. GPS and
/// compass are listened to only while this bloc is alive, i.e. while the
/// screen is open. A missing point or fix is a failure; a missing compass
/// is not — the distance still shows, without an arrow.
final class NavigationGuidanceBloc extends DataBloc<NavigationGuidance> {
  NavigationGuidanceBloc(
    this._points,
    this._location,
    this._compass, {
    required this.pointId,
    AppLogger logger = const NoopLogger(),
  }) : _telemetry = NavigationTelemetry(logger, pointId: pointId);

  final PointsRepository _points;
  final LocationRepository _location;
  final CompassRepository _compass;
  final String pointId;
  final NavigationTelemetry _telemetry;

  @override
  Stream<Result<NavigationGuidance>> watch() async* {
    switch (await _points.getById(pointId)) {
      case Failed(:final failure):
        yield Result.failure(failure);
      case Success(value: final point):
        yield* _guide(point);
    }
  }

  Stream<Result<NavigationGuidance>> _guide(SavedPoint point) {
    late final StreamController<Result<NavigationGuidance>> controller;
    final subscriptions = <StreamSubscription<Object>>[];
    LocationFix? fix;
    Result<CompassReading>? compass;
    double? arrow;
    var arrived = false;

    void publish() {
      final here = fix;
      if (here == null) return;
      final distance = distanceMeters(here.point, point.position);
      final status = switch (compass) {
        Success(value: final reading) when reading.isUnreliable =>
          CompassStatus.unreliable,
        Success() => CompassStatus.ok,
        Failed() => CompassStatus.unavailable,
        null => CompassStatus.ok,
      };
      final bearing = bearingDegrees(here.point, point.position);
      if (compass case Success(value: final reading)) {
        final target = arrowRotationDegrees(
          bearingDegrees: bearing,
          headingDegrees: reading.headingDegrees,
        );
        arrow = switch (arrow) {
          final previous? => continuousRotationDegrees(previous, target),
          null => target,
        };
      }
      arrived = hasArrived(
        distanceMeters: distance,
        accuracyMeters: here.accuracyMeters,
        wasArrived: arrived,
      );
      final guidance = NavigationGuidance(
        point: point,
        distanceMeters: distance,
        accuracyMeters: here.accuracyMeters,
        weakSignal: here.isWeakSignal,
        arrived: arrived,
        compass: status,
        arrowDegrees: status == CompassStatus.unavailable ? null : arrow,
      );
      _telemetry.guided(
        fix: here,
        guidance: guidance,
        bearingDegrees: bearing,
        reading: compass?.valueOrNull,
      );
      controller.add(Result.success(guidance));
    }

    controller = StreamController(
      onListen: () {
        _telemetry.started();
        subscriptions
          ..add(
            _location.watchFix().listen((result) {
              switch (result) {
                case Success(:final value):
                  fix = value;
                  publish();
                case Failed(:final failure):
                  _telemetry.failed(failure.code);
                  controller.add(Result.failure(failure));
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
        _telemetry.stopped();
        await Future.wait([
          for (final subscription in subscriptions) subscription.cancel(),
        ]);
      },
    );
    return controller.stream;
  }
}
