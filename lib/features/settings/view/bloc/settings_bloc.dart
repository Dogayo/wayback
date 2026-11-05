import 'package:wayback/core/bloc/data/data_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';

export 'package:wayback/core/bloc/data/data_bloc.dart';

/// The current settings and every change. One instance above the app
/// applies them everywhere; the settings screen shows the same one.
final class SettingsBloc extends DataBloc<AppSettings> {
  SettingsBloc(this._settings);

  final SettingsRepository _settings;

  @override
  Stream<Result<AppSettings>> watch() => _settings.watch();
}
