import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/navigation/data/datasources/compass_datasource.dart';
import 'package:wayback/features/navigation/data/mappers/compass_reading_mapper.dart';
import 'package:wayback/features/navigation/domain/entities/compass_reading.dart';
import 'package:wayback/features/navigation/domain/repositories/compass_repository.dart';

final class CompassRepositoryImpl
    with ResultHandler
    implements CompassRepository {
  const CompassRepositoryImpl(
    this._datasource, {
    this.resultOptions = const ResultHandlerOptions(),
  });

  final CompassDatasource _datasource;

  @override
  final ResultHandlerOptions resultOptions;

  @override
  Stream<Result<CompassReading>> watchHeading() =>
      handleStream(_datasource.watchHeading().map((model) => model.toEntity()));
}
