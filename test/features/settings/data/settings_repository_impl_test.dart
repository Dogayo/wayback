import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:wayback/features/settings/data/datasources/shared_preferences_settings_datasource.dart';
import 'package:wayback/features/settings/data/models/settings_model.dart';
import 'package:wayback/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';

const _key = SharedPreferencesSettingsDatasource.storageKey;

Future<SettingsRepositoryImpl> _build([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return SettingsRepositoryImpl(
    SharedPreferencesSettingsDatasource(await SharedPreferences.getInstance()),
  );
}

Future<AppSettings> _current(SettingsRepository repository) async =>
    (await repository.watch().first).valueOrNull!;

final class _BrokenDatasource implements SettingsLocalDatasource {
  @override
  Future<SettingsModel?> read() async => null;

  @override
  Future<void> write(SettingsModel settings) async =>
      throw const StorageException(code: SettingsErrorCodes.storageFailed);
}

void main() {
  test('nothing stored reads as defaults', () async {
    final settings = await _current(await _build());
    expect(settings, AppSettings.defaults);
    expect(settings.units, UnitSystem.metric);
    expect(settings.language, AppLanguage.system);
    expect(settings.vibrationOnArrival, isTrue);
  });

  test('changes are streamed and survive a restart', () async {
    final repository = await _build();
    final seen = <AppSettings>[];
    final subscription = repository.watch().listen(
      (result) => seen.add(result.valueOrNull!),
    );
    addTearDown(subscription.cancel);
    await pumpEventQueue();

    await repository.setUnits(UnitSystem.imperial);
    await repository.setLanguage(AppLanguage.en);
    await repository.setVibrationOnArrival(enabled: false);
    await pumpEventQueue();

    expect(seen, hasLength(4));
    expect(seen.last.language, AppLanguage.en);
    final stored = (await SharedPreferences.getInstance()).getString(_key)!;
    final restarted = await _current(await _build({_key: stored}));
    expect(
      restarted,
      const AppSettings(
        units: UnitSystem.imperial,
        language: AppLanguage.en,
        vibrationOnArrival: false,
      ),
    );
  });

  test('unknown values from a newer version fall back to defaults', () async {
    final settings = await _current(
      await _build({_key: '{"units":"parsecs","language":"de"}'}),
    );
    expect(settings, AppSettings.defaults);
  });

  test('unreadable storage is a settings failure, not an exception', () async {
    final result = await (await _build({_key: 'not json'})).watch().first;
    expect(result.failureOrNull?.code, SettingsErrorCodes.storageFailed);
  });

  test('a failed write keeps the old settings', () async {
    final repository = SettingsRepositoryImpl(_BrokenDatasource());

    final result = await repository.setUnits(UnitSystem.imperial);

    expect(result.failureOrNull?.code, SettingsErrorCodes.storageFailed);
    expect((await _current(repository)).units, UnitSystem.metric);
  });
}
