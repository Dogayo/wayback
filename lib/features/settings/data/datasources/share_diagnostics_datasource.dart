import 'package:app_logger/app_logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/features/settings/data/datasources/diagnostics_datasource.dart';
import 'package:wayback/features/settings/domain/repositories/diagnostics_repository.dart';

/// Hands the exported log to the system share sheet; no network of our own.
final class ShareDiagnosticsDatasource implements DiagnosticsDatasource {
  const ShareDiagnosticsDatasource(this._logger);

  final AppLogger _logger;

  @override
  Future<void> shareLog({required String subject}) async {
    final file = await _logger.exportShareable();
    if (file == null) {
      throw const StorageException(
        code: DiagnosticsErrorCodes.exportFailed,
        description: 'No log to export',
      );
    }
    try {
      await SharePlus.instance.share(
        ShareParams(subject: subject, files: [XFile(file.path)]),
      );
    } on Object catch (error, stackTrace) {
      throw StorageException(
        code: DiagnosticsErrorCodes.exportFailed,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
