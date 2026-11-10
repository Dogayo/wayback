import 'package:wayback/core/result/result.dart';

/// Failure codes [DiagnosticsRepository] can return (architecture.md §4.2).
abstract final class DiagnosticsErrorCodes {
  static const exportFailed = 'diagnostics_export_failed';
}

/// Every method returns a [Result]; none of them throws.
abstract interface class DiagnosticsRepository {
  /// Opens the system share sheet with the log, without coordinates
  /// (mvp-scope.md §2.7). Closing the sheet is not a failure.
  Future<Result<void>> shareLog({required String subject});
}
