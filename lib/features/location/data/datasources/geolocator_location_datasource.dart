import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:wayback/core/error/exceptions.dart' hide TimeoutException;
import 'package:wayback/features/location/data/datasources/location_datasource.dart';
import 'package:wayback/features/location/data/models/location_fix_model.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

/// How long a single fix may take before it counts as unavailable.
const _fixTimeout = Duration(seconds: 20);

/// Smallest movement, meters, that produces a new fix while navigating.
const _distanceFilterMeters = 1;

final class GeolocatorLocationDatasource implements LocationDatasource {
  const GeolocatorLocationDatasource();

  @override
  Future<LocationAccess> checkAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.serviceDisabled;
    }
    return _access(await Geolocator.checkPermission());
  }

  @override
  Future<LocationAccess> requestAccess() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.serviceDisabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return _access(permission);
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

  @override
  Stream<LocationFixModel> watchFix() =>
      Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              distanceFilter: _distanceFilterMeters,
            ),
          )
          .map(_model)
          .handleError(
            (Object error, StackTrace stackTrace) =>
                throw _exception(error, stackTrace),
          );

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
