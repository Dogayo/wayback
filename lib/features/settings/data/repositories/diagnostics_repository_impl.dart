import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/settings/data/datasources/diagnostics_datasource.dart';
import 'package:wayback/features/settings/domain/repositories/diagnostics_repository.dart';

final class DiagnosticsRepositoryImpl
    with ResultHandler
    implements DiagnosticsRepository {
  DiagnosticsRepositoryImpl(
    this._datasource, {
    this.resultOptions = const ResultHandlerOptions(),
  });

  final DiagnosticsDatasource _datasource;

  @override
  final ResultHandlerOptions resultOptions;

  @override
  Future<Result<void>> shareLog({required String subject}) =>
      handle(() => _datasource.shareLog(subject: subject));
}
