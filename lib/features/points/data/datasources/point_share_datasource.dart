/// Throws `StorageException` with a `PointShareErrorCodes` code.
abstract interface class PointShareDatasource {
  Future<void> shareText(String text);
}
