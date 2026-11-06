import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:wayback/core/error/exceptions.dart' hide TimeoutException;
import 'package:wayback/features/location/data/datasources/location_datasource.dart';
import 'package:wayback/features/location/data/models/location_fix_model.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

/// How long a single fix may take before it counts as unavailable.
const _fixTimeout = Duration(seconds: 20);

/// How long the plugin may stay silent after the first subscription before
/// it is asked again (see [GeolocatorLocationDatasource.watchFix]).
const _serviceBindGrace = Duration(seconds: 3);

/// Smallest movement, meters, that produces a new fix while navigating.
const _distanceFilterMeters = 1;

final class GeolocatorLocationDatasource implements LocationDatasource {
  const GeolocatorLocationDatasource();

  @override
  Future<LocationAccess> checkAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.serviceDisabled;
    }
    return _precision(_access(await Geolocator.checkPermission()));
  }

  @override
  Future<LocationAccess> requestAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.serviceDisabled;
    }
    final access = await _precision(
      _access(await Geolocator.checkPermission()),
    );
    // Asking again with approximate access offers precise on Android.
    if (access != LocationAccess.denied &&
        access != LocationAccess.approximate) {
      return access;
    }
    return _precision(_access(await Geolocator.requestPermission()));
  }

  static Future<LocationAccess> _precision(LocationAccess access) async {
    if (access != LocationAccess.granted) return access;
    final accuracy = await Geolocator.getLocationAccuracy();
    return accuracy == LocationAccuracyStatus.reduced
        ? LocationAccess.approximate
        : access;
  }

  @override
  Future<LocationFixModel> currentFix() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: _fixTimeout),
      );
      return _model(position);
    } on Object catch (error, stackTrace) {
      throw _exception(error, stackTrace);
    }
  }

  /// On a cold start the Android plugin may get the subscription before its
  /// location service is bound; it then logs "Location background service
  /// has not started correctly" and stays silent — no fix, no error. If
  /// nothing came within [_serviceBindGrace], subscribe once more: by then the
  /// service is bound, and a second request is harmless otherwise.
  @override
  Stream<LocationFixModel> watchFix() {
    late final StreamController<LocationFixModel> controller;
    StreamSubscription<Position>? subscription;
    Timer? silence;

    void listen({required bool retryOnSilence}) {
      subscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              distanceFilter: _distanceFilterMeters,
            ),
          ).listen(
            (position) {
              silence?.cancel();
              controller.add(_model(position));
            },
            onError: (Object error, StackTrace stackTrace) {
              silence?.cancel();
              controller.addError(_exception(error, stackTrace), stackTrace);
            },
            onDone: controller.close,
          );
      if (retryOnSilence) {
        silence = Timer(_serviceBindGrace, () async {
          await subscription?.cancel();
          listen(retryOnSilence: false);
        });
      }
    }

    controller = StreamController(
      onListen: () => listen(retryOnSilence: true),
      onCancel: () async {
        silence?.cancel();
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  @override
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  static LocationAccess _access(LocationPermission permission) =>
      switch (permission) {
        LocationPermission.whileInUse ||
        LocationPermission.always => LocationAccess.granted,
        LocationPermission.deniedForever => LocationAccess.deniedForever,
        LocationPermission.denied ||
        LocationPermission.unableToDetermine => LocationAccess.denied,
      };

  static LocationFixModel _model(Position position) => LocationFixModel(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracyMeters: position.accuracy,
    timestamp: position.timestamp,
    altitudeMeters: position.hasAltitude ? position.altitude : null,
  );

  static LocalException _exception(Object error, StackTrace stackTrace) =>
      switch (error) {
        LocalException() => error,
        LocationServiceDisabledException() => SensorException(
          code: LocationErrorCodes.serviceDisabled,
          cause: error,
          stackTrace: stackTrace,
        ),
        PermissionDeniedException() => PermissionException(
          code: LocationErrorCodes.permissionDenied,
          description: error.message,
          cause: error,
          stackTrace: stackTrace,
        ),
        _ => SensorException(
          code: LocationErrorCodes.unavailable,
          description: '$error',
          cause: error,
          stackTrace: stackTrace,
        ),
      };
}
