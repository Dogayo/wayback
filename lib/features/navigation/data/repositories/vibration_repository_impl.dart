import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/navigation/data/datasources/vibration_datasource.dart';
import 'package:wayback/features/navigation/domain/repositories/vibration_repository.dart';

final class VibrationRepositoryImpl
    with ResultHandler
    implements VibrationRepository {
  const VibrationRepositoryImpl(
    this._datasource, {
    this.resultOptions = const ResultHandlerOptions(),
  });

  final VibrationDatasource _datasource;

  @override
  final ResultHandlerOptions resultOptions;

  @override
  Future<Result<void>> vibrate() => handle(_datasource.vibrate);
}
