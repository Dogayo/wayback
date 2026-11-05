import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Turns the vibration on entering the arrival radius on or off.
final class SetVibrationOnArrivalBloc extends ActionBloc<bool, void> {
  SetVibrationOnArrivalBloc(this._settings);

  final SettingsRepository _settings;

  @override
  Future<Result<void>> perform(bool params) =>
      _settings.setVibrationOnArrival(enabled: params);
}
