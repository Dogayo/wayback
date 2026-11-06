/// Throws `StorageException` with a `DiagnosticsErrorCodes` code.
abstract interface class DiagnosticsDatasource {
  Future<void> shareLog({required String subject});
}
