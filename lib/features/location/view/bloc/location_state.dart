import 'package:wayback/core/error/failures.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';

sealed class LocationState {
  const LocationState();
}

/// Access is being checked or the first fix has not arrived yet.
final class LocationLoading extends LocationState {
  const LocationLoading();
}

/// The system dialog has not been shown yet; the user starts it.
final class LocationPermissionNeeded extends LocationState {
  const LocationPermissionNeeded();
}

final class LocationReady extends LocationState {
  const LocationReady(this.fix);

  final LocationFix fix;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is LocationReady && other.fix == fix;

  @override
  int get hashCode => fix.hashCode;
}

final class LocationError extends LocationState {
  const LocationError(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationError && other.failure == failure;

  @override
  int get hashCode => failure.hashCode;
}
