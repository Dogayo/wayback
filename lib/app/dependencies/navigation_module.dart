import 'package:app_di/app_di.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/navigation/data/datasources/compass_datasource.dart';
import 'package:wayback/features/navigation/data/datasources/flutter_compass_datasource.dart';
import 'package:wayback/features/navigation/data/datasources/plugin_vibration_datasource.dart';
import 'package:wayback/features/navigation/data/datasources/vibration_datasource.dart';
import 'package:wayback/features/navigation/data/repositories/compass_repository_impl.dart';
import 'package:wayback/features/navigation/data/repositories/vibration_repository_impl.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';
import 'package:wayback/features/navigation/domain/repositories/vibration_repository.dart';

final class NavigationModule extends DependencyCollection {
  const NavigationModule();

  @override
  Iterable<RegType> get dependencies => [
    RegFactory<CompassDatasource>(
      (_) => const FlutterCompassDatasource(),
      isSingleton: true,
    ),
    RegFactory<CompassRepository>(
      (i) => CompassRepositoryImpl(
        i.get<CompassDatasource>(),
        resultOptions: i.get<ResultHandlerOptions>(),
      ),
      isSingleton: true,
    ),
    RegFactory<VibrationDatasource>(
      (_) => const PluginVibrationDatasource(),
      isSingleton: true,
    ),
    RegFactory<VibrationRepository>(
      (i) => VibrationRepositoryImpl(
        i.get<VibrationDatasource>(),
        resultOptions: i.get<ResultHandlerOptions>(),
      ),
      isSingleton: true,
    ),
  ];
}
