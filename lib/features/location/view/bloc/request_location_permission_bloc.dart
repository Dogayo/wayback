import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Shows the system location dialog; started by the "Allow" action.
final class RequestLocationPermissionBloc
    extends ActionBloc<void, LocationAccess> {
  RequestLocationPermissionBloc(this._repository);

  final LocationRepository _repository;

  @override
  Future<Result<LocationAccess>> perform(void params) =>
      _repository.requestAccess();
}
