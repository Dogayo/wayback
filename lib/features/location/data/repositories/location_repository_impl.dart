import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/location/data/datasources/location_datasource.dart';
import 'package:wayback/features/location/data/mappers/location_fix_mapper.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

final class LocationRepositoryImpl
    with ResultHandler
    implements LocationRepository {
  const LocationRepositoryImpl(
    this._datasource, {
    this.resultOptions = const ResultHandlerOptions(),
  });

  final LocationDatasource _datasource;

  @override
  final ResultHandlerOptions resultOptions;

  @override
  Future<Result<LocationAccess>> checkAccess() =>
      handle(_datasource.checkAccess);

  @override
  Future<Result<LocationAccess>> requestAccess() =>
      handle(_datasource.requestAccess);

  @override
  Future<Result<LocationFix>> currentFix() =>
      handle(() async => (await _datasource.currentFix()).toEntity());

  @override
  Stream<Result<LocationFix>> watchFix() =>
      handleStream(_datasource.watchFix().map((model) => model.toEntity()));

  @override
  Future<Result<void>> openAppSettings() => handle(_datasource.openAppSettings);

  @override
  Future<Result<void>> openLocationSettings() =>
      handle(_datasource.openLocationSettings);
}
