import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Switches between metric and imperial distances.
final class SetUnitsBloc extends ActionBloc<UnitSystem, void> {
  SetUnitsBloc(this._settings);

  final SettingsRepository _settings;

  @override
  Future<Result<void>> perform(UnitSystem params) => _settings.setUnits(params);
}
