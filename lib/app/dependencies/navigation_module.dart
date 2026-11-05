import 'package:app_di/app_di.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/navigation/data/datasources/compass_datasource.dart';
import 'package:wayback/features/navigation/data/datasources/flutter_compass_datasource.dart';
import 'package:wayback/features/navigation/data/repositories/compass_repository_impl.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';

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
  ];
}
