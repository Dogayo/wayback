import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';

/// Failure codes [SettingsRepository] can return (architecture.md §4.2).
abstract final class SettingsErrorCodes {
  static const storageFailed = 'settings_storage_failed';
}

/// Every method returns a [Result]; none of them throws.
abstract interface class SettingsRepository {
  /// Current settings, then every change.
  Stream<Result<AppSettings>> watch();

  Future<Result<void>> setUnits(UnitSystem units);

  Future<Result<void>> setLanguage(AppLanguage language);

  Future<Result<void>> setVibrationOnArrival({required bool enabled});

  Future<Result<void>> setVibrationPattern(VibrationPattern pattern);
}
