import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/location/view/bloc/location_state.dart';

export 'package:wayback/features/location/view/bloc/location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this._repository) : super(const LocationLoading());

  final LocationRepository _repository;
  StreamSubscription<Result<LocationFix>>? _subscription;

  /// Checks access without asking and starts listening once it is granted.
  Future<void> start() async {
    _onAccess(await _repository.checkAccess());
  }

  /// Shows the system dialog; called from the "Allow" action.
  Future<void> requestPermission() async {
    emit(const LocationLoading());
    _onAccess(await _repository.requestAccess());
  }

  /// Opens the screen that can lift the current error.
  Future<void> openSettings() => switch (state) {
    LocationError(failure: Failure(code: LocationErrorCodes.serviceDisabled)) =>
      _repository.openLocationSettings(),
    _ => _repository.openAppSettings(),
  };

  void _onAccess(Result<LocationAccess> result) {
    switch (result) {
      case Failed(:final failure):
        _stop();
        emit(LocationError(failure));
      case Success(value: LocationAccess.granted):
        _listen();
      case Success(value: LocationAccess.denied):
        _stop();
        emit(const LocationPermissionNeeded());
      case Success(value: LocationAccess.deniedForever):
        _stop();
        emit(
          const LocationError(
            PermissionFailure(code: LocationErrorCodes.permissionDeniedForever),
          ),
        );
      case Success(value: LocationAccess.serviceDisabled):
        _stop();
        emit(
          const LocationError(
            SensorFailure(code: LocationErrorCodes.serviceDisabled),
          ),
        );
    }
  }

  void _listen() {
    if (_subscription != null) return;
    if (state is! LocationReady) emit(const LocationLoading());
    _subscription = _repository.watchFix().listen(
      (result) => emit(switch (result) {
        Success(:final value) => LocationReady(value),
        Failed(:final failure) => LocationError(failure),
      }),
    );
  }

  void _stop() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
