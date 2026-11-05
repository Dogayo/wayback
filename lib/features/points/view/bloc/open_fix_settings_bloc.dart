import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Opens the system screen that can give the new point a fix back: the
/// location switch for `serviceDisabled`, the app permissions otherwise.
///
/// Points use the location domain only, so this mirrors the location
/// feature's settings action instead of importing its view.
final class OpenFixSettingsBloc extends ActionBloc<String, void> {
  OpenFixSettingsBloc(this._location);

  final LocationRepository _location;

  @override
  Future<Result<void>> perform(String failureCode) =>
      failureCode == LocationErrorCodes.serviceDisabled
      ? _location.openLocationSettings()
      : _location.openAppSettings();
}
