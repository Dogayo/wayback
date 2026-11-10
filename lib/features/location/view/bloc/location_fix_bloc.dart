import 'package:wayback/core/bloc/data/data_bloc.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

export 'package:wayback/core/bloc/data/data_bloc.dart';

/// The user's position for the screen it sits on.
///
/// Checks access without asking first. Missing access arrives as a failure
/// with a [LocationErrorCodes] code: `permissionDenied` (the system dialog
/// can still be shown), `preciseRequired`, `permissionDeniedForever`,
/// `serviceDisabled`.
final class LocationFixBloc extends DataBloc<LocationFix> {
  LocationFixBloc(this._repository);

  final LocationRepository _repository;

  @override
  Stream<Result<LocationFix>> watch() async* {
    switch (await _repository.checkAccess()) {
      case Failed(:final failure):
        yield Result.failure(failure);
      case Success(value: LocationAccess.granted):
        yield* _repository.watchFix();
      case Success(value: LocationAccess.approximate):
        yield const Result.failure(
          PermissionFailure(code: LocationErrorCodes.preciseRequired),
        );
      case Success(value: LocationAccess.denied):
        yield const Result.failure(
          PermissionFailure(code: LocationErrorCodes.permissionDenied),
        );
      case Success(value: LocationAccess.deniedForever):
        yield const Result.failure(
          PermissionFailure(code: LocationErrorCodes.permissionDeniedForever),
        );
      case Success(value: LocationAccess.serviceDisabled):
        yield const Result.failure(
          SensorFailure(code: LocationErrorCodes.serviceDisabled),
        );
    }
  }
}
