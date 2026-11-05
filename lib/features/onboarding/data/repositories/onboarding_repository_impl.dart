import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:wayback/features/onboarding/domain/repositories/onboarding_repository.dart';

final class OnboardingRepositoryImpl
    with ResultHandler
    implements OnboardingRepository {
  OnboardingRepositoryImpl(
    this._datasource, {
    this.resultOptions = const ResultHandlerOptions(),
  });

  final OnboardingLocalDatasource _datasource;

  /// The router asks on every navigation; the datasource is read once.
  bool? _completed;

  @override
  final ResultHandlerOptions resultOptions;

  @override
  Future<Result<bool>> isCompleted() =>
      handle(() async => _completed ??= await _datasource.readCompleted());

  @override
  Future<Result<void>> complete() {
    _completed = true;
    return handle(_datasource.writeCompleted);
  }
}
