import 'package:share_plus/share_plus.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/features/points/data/datasources/point_share_datasource.dart';
import 'package:wayback/features/points/domain/repositories/point_share_repository.dart';

/// Hands the text to the system share sheet; no network of our own.
final class SystemPointShareDatasource implements PointShareDatasource {
  const SystemPointShareDatasource();

  @override
  Future<void> shareText(String text) async {
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } on Object catch (error, stackTrace) {
      throw StorageException(
        code: PointShareErrorCodes.shareFailed,
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
