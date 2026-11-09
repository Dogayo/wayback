import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/points/domain/repositories/point_share_repository.dart';

/// Records what would have gone to the share sheet.
final class FakePointShareRepository implements PointShareRepository {
  final shared = <String>[];
  Failure? failNext;

  @override
  Future<Result<void>> shareText(String text) async {
    if (failNext case final failure?) {
      failNext = null;
      return Result.failure(failure);
    }
    shared.add(text);
    return const Result.success(null);
  }
}
