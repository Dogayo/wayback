import 'package:wayback/core/result/result.dart';

/// Failure codes [PointShareRepository] can return (architecture.md §4.2).
abstract final class PointShareErrorCodes {
  static const shareFailed = 'point_share_failed';
}

/// Every method returns a [Result]; none of them throws.
abstract interface class PointShareRepository {
  /// Opens the system share sheet with [text]. Closing it is not a failure.
  Future<Result<void>> shareText(String text);
}
