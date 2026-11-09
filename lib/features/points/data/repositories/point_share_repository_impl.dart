import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/points/data/datasources/point_share_datasource.dart';
import 'package:wayback/features/points/domain/repositories/point_share_repository.dart';

final class PointShareRepositoryImpl
    with ResultHandler
    implements PointShareRepository {
  PointShareRepositoryImpl(
    this._datasource, {
    this.resultOptions = const ResultHandlerOptions(),
  });

  final PointShareDatasource _datasource;

  @override
  final ResultHandlerOptions resultOptions;

  @override
  Future<Result<void>> shareText(String text) =>
      handle(() => _datasource.shareText(text));
}
