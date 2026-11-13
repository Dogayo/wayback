import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Chooses the light or the dark theme, or goes back to the system one.
final class SetThemeModeBloc extends ActionBloc<AppThemeMode, void> {
  SetThemeModeBloc(this._settings);

  final SettingsRepository _settings;

  @override
  Future<Result<void>> perform(AppThemeMode params) =>
      _settings.setThemeMode(params);
}
