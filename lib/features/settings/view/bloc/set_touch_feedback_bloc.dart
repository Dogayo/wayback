import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Turns the short vibrations on selections and results on or off.
final class SetTouchFeedbackBloc extends ActionBloc<bool, void> {
  SetTouchFeedbackBloc(this._settings);

  final SettingsRepository _settings;

  @override
  Future<Result<void>> perform(bool params) =>
      _settings.setTouchFeedback(enabled: params);
}
