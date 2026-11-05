import 'package:app_di/app_di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:wayback/features/settings/data/datasources/shared_preferences_settings_datasource.dart';
import 'package:wayback/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';

final class SettingsModule extends DependencyCollection {
  const SettingsModule(this._preferences);

  /// Initialized in bootstrap before the container is built.
  final SharedPreferences _preferences;

  @override
  Iterable<RegType> get dependencies => [
    RegFactory<SettingsLocalDatasource>(
      (_) => SharedPreferencesSettingsDatasource(_preferences),
      isSingleton: true,
    ),
    // Singleton: it holds the cache and the change stream the app listens to.
    RegFactory<SettingsRepository>(
      (i) => SettingsRepositoryImpl(
        i.get<SettingsLocalDatasource>(),
        resultOptions: i.get<ResultHandlerOptions>(),
      ),
      isSingleton: true,
    ),
  ];
}
