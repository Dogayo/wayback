import 'package:wayback/features/settings/data/models/settings_model.dart';

/// Throws `StorageException` with a `SettingsErrorCodes` code.
abstract interface class SettingsLocalDatasource {
  /// `null` until something is saved.
  Future<SettingsModel?> read();

  Future<void> write(SettingsModel settings);
}
