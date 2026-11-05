import 'dart:async';

import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:wayback/features/settings/data/mappers/settings_mapper.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';

final class SettingsRepositoryImpl
    with ResultHandler
    implements SettingsRepository {
  SettingsRepositoryImpl(
    this._datasource, {
    this.resultOptions = const ResultHandlerOptions(),
  });

  final SettingsLocalDatasource _datasource;
  final _changes = StreamController<AppSettings>.broadcast();

  /// Last settings read or written; the datasource is read once.
  AppSettings? _cache;

  @override
  final ResultHandlerOptions resultOptions;

  @override
  Stream<Result<AppSettings>> watch() => handleStream(_watch());

  @override
  Future<Result<void>> setUnits(UnitSystem units) =>
      handle(() => _update((settings) => settings.copyWith(units: units)));

  @override
  Future<Result<void>> setLanguage(AppLanguage language) => handle(
    () => _update((settings) => settings.copyWith(language: language)),
  );

  @override
  Future<Result<void>> setVibrationOnArrival({required bool enabled}) => handle(
    () => _update((settings) => settings.copyWith(vibrationOnArrival: enabled)),
  );

  Stream<AppSettings> _watch() async* {
    yield await _settings();
    yield* _changes.stream;
  }

  Future<AppSettings> _settings() async =>
      _cache ??= (await _datasource.read())?.toEntity() ?? AppSettings.defaults;

  Future<void> _update(
    AppSettings Function(AppSettings settings) change,
  ) async {
    final updated = change(await _settings());
    await _datasource.write(updated.toModel());
    _cache = updated;
    _changes.add(updated);
  }
}
