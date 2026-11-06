import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/settings/domain/repositories/diagnostics_repository.dart';

/// Records what was shared; [failNext] makes the next call fail with it.
final class FakeDiagnosticsRepository implements DiagnosticsRepository {
  final subjects = <String>[];
  Failure? failNext;

  @override
  Future<Result<void>> shareLog({required String subject}) async {
    if (failNext case final failure?) {
      failNext = null;
      return Result.failure(failure);
    }
    subjects.add(subject);
    return const Result.success(null);
  }
}
