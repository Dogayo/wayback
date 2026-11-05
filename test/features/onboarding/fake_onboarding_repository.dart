import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/onboarding/domain/repositories/onboarding_repository.dart';

/// In-memory flag; [failNext] makes the next save fail with it.
final class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({this.completed = true});

  bool completed;
  Failure? failNext;

  @override
  Future<Result<bool>> isCompleted() async => Result.success(completed);

  @override
  Future<Result<void>> complete() async {
    completed = true;
    if (failNext case final failure?) {
      failNext = null;
      return Result.failure(failure);
    }
    return const Result.success(null);
  }
}
