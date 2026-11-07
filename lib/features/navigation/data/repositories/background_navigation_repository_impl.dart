import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/navigation/data/datasources/background_navigation_datasource.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_notice.dart';
import 'package:wayback/features/navigation/domain/repositories/background_navigation_repository.dart';

final class BackgroundNavigationRepositoryImpl
    with ResultHandler
    implements BackgroundNavigationRepository {
  const BackgroundNavigationRepositoryImpl(
    this._datasource, {
    this.resultOptions = const ResultHandlerOptions(),
  });

  final BackgroundNavigationDatasource _datasource;

  @override
  final ResultHandlerOptions resultOptions;

  @override
  Future<Result<void>> show(NavigationNotice notice) =>
      handle(() => _datasource.show(notice));

  @override
  Future<Result<void>> stop() => handle(_datasource.stop);

  @override
  Stream<Result<void>> watchStopRequests() =>
      handleStream(_datasource.watchStopRequests());
}
