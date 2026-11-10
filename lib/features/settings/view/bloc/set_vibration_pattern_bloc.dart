import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Picks the vibration played on arrival.
final class SetVibrationPatternBloc extends ActionBloc<VibrationPattern, void> {
  SetVibrationPatternBloc(this._settings);

  final SettingsRepository _settings;

  @override
  Future<Result<void>> perform(VibrationPattern params) =>
      _settings.setVibrationPattern(params);
}
