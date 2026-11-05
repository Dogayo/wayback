import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';

/// Failure codes [LocationRepository] can return (architecture.md §4.2).
abstract final class LocationErrorCodes {
  static const permissionDenied = 'location_permission_denied';
  static const permissionDeniedForever = 'location_permission_denied_forever';
  static const serviceDisabled = 'location_service_disabled';
  static const unavailable = 'location_unavailable';
}

/// Every method returns a [Result]; none of them throws.
abstract interface class LocationRepository {
  /// Current access, without asking the user.
  Future<Result<LocationAccess>> checkAccess();

  /// Shows the system dialog when it still can be shown.
  Future<Result<LocationAccess>> requestAccess();

  /// One fresh fix, for saving a point.
  Future<Result<LocationFix>> currentFix();

  /// Fixes while navigating. A failure does not end the stream.
  Stream<Result<LocationFix>> watchFix();

  Future<Result<void>> openAppSettings();

  Future<Result<void>> openLocationSettings();
}
