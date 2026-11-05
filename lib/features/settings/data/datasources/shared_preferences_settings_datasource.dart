import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:wayback/features/settings/data/models/settings_model.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';

/// All settings as one JSON object under a versioned key.
final class SharedPreferencesSettingsDatasource
    implements SettingsLocalDatasource {
  const SharedPreferencesSettingsDatasource(this._preferences);

  static const storageKey = 'settings.v1';

  final SharedPreferences _preferences;

  @override
  Future<SettingsModel?> read() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return null;
    try {
      return SettingsModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object catch (error, stackTrace) {
      throw StorageException(
        code: SettingsErrorCodes.storageFailed,
        description: 'Stored settings are not readable',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> write(SettingsModel settings) async {
    final bool saved;
    try {
      saved = await _preferences.setString(
        storageKey,
        jsonEncode(settings.toJson()),
      );
    } on Object catch (error, stackTrace) {
      throw StorageException(
        code: SettingsErrorCodes.storageFailed,
        cause: error,
        stackTrace: stackTrace,
      );
    }
    if (!saved) {
      throw const StorageException(
        code: SettingsErrorCodes.storageFailed,
        description: 'SharedPreferences refused the write',
      );
    }
  }
}
