/// Throws `StorageException` with an `OnboardingErrorCodes` code.
abstract interface class OnboardingLocalDatasource {
  Future<bool> readCompleted();

  Future<void> writeCompleted();
}
