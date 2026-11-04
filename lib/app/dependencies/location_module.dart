import 'package:app_di/app_di.dart';

import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/location/data/datasources/geolocator_location_datasource.dart';
import 'package:wayback/features/location/data/datasources/location_datasource.dart';
import 'package:wayback/features/location/data/repositories/location_repository_impl.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

final class LocationModule extends DependencyCollection {
  const LocationModule();

  @override
  Iterable<RegType> get dependencies => [
    RegFactory<LocationDatasource>(
      (_) => const GeolocatorLocationDatasource(),
      isSingleton: true,
    ),
    RegFactory<LocationRepository>(
      (i) => LocationRepositoryImpl(
        i.get<LocationDatasource>(),
        resultOptions: i.get<ResultHandlerOptions>(),
      ),
      isSingleton: true,
    ),
  ];
}
