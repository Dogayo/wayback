import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:wayback/features/onboarding/domain/repositories/onboarding_repository.dart';

/// One flag under a versioned key: a new onboarding that everyone should
/// see again gets a new key.
final class SharedPreferencesOnboardingDatasource
    implements OnboardingLocalDatasource {
  const SharedPreferencesOnboardingDatasource(this._preferences);

  static const storageKey = 'onboarding.completed.v1';

  final SharedPreferences _preferences;

  @override
  Future<bool> readCompleted() async {
    try {
      return _preferences.getBool(storageKey) ?? false;
    } on Object catch (error, stackTrace) {
      throw StorageException(
        code: OnboardingErrorCodes.storageFailed,
        description: 'Stored onboarding flag is not readable',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> writeCompleted() async {
    final bool saved;
    try {
      saved = await _preferences.setBool(storageKey, true);
    } on Object catch (error, stackTrace) {
      throw StorageException(
        code: OnboardingErrorCodes.storageFailed,
        cause: error,
        stackTrace: stackTrace,
      );
    }
    if (!saved) {
      throw const StorageException(
        code: OnboardingErrorCodes.storageFailed,
        description: 'SharedPreferences refused the write',
      );
    }
  }
}
