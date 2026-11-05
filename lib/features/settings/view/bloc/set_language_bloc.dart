import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Chooses the interface language or goes back to the system one.
final class SetLanguageBloc extends ActionBloc<AppLanguage, void> {
  SetLanguageBloc(this._settings);

  final SettingsRepository _settings;

  @override
  Future<Result<void>> perform(AppLanguage params) =>
      _settings.setLanguage(params);
}
