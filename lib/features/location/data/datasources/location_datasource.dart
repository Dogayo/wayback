import 'package:wayback/features/location/data/models/location_fix_model.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

/// Throws `PermissionException` or `SensorException` with a
/// [LocationErrorCodes] code; streams report the same as errors.
abstract interface class LocationDatasource {
  Future<LocationAccess> checkAccess();

  Future<LocationAccess> requestAccess();

  Future<LocationFixModel> currentFix();

  Stream<LocationFixModel> watchFix();

  Future<void> openAppSettings();

  Future<void> openLocationSettings();
}
