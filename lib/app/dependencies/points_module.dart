import 'package:app_di/app_di.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/points/data/datasources/points_local_datasource.dart';
import 'package:wayback/features/points/data/datasources/shared_preferences_points_datasource.dart';
import 'package:wayback/features/points/data/repositories/points_repository_impl.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

final class PointsModule extends DependencyCollection {
  const PointsModule(this._preferences);

  /// Initialized in bootstrap before the container is built.
  final SharedPreferences _preferences;

  @override
  Iterable<RegType> get dependencies => [
    RegFactory<PointsLocalDatasource>(
      (_) => SharedPreferencesPointsDatasource(_preferences),
      isSingleton: true,
    ),
    // Singleton: it holds the cache and the change stream every screen uses.
    RegFactory<PointsRepository>(
      (i) => PointsRepositoryImpl(
        i.get<PointsLocalDatasource>(),
        resultOptions: i.get<ResultHandlerOptions>(),
      ),
      isSingleton: true,
    ),
  ];
}
