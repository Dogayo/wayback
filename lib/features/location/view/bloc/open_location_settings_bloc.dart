import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Opens the system screen that can lift a location failure: the location
/// switch for `serviceDisabled`, the app permissions otherwise.
///
/// The parameter is the failure code being fixed.
final class OpenLocationSettingsBloc extends ActionBloc<String, void> {
  OpenLocationSettingsBloc(this._repository);

  final LocationRepository _repository;

  @override
  Future<Result<void>> perform(String failureCode) =>
      failureCode == LocationErrorCodes.serviceDisabled
      ? _repository.openLocationSettings()
      : _repository.openAppSettings();
}
