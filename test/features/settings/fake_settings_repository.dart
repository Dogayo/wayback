import 'dart:async';

import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/settings/domain/entities/app_settings.dart';
import 'package:wayback/features/settings/domain/repositories/settings_repository.dart';

/// In-memory settings; [failNext] makes the next write fail with it,
/// [readFailure] makes reading fail.
final class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this.settings = AppSettings.defaults]);

  AppSettings settings;
  Failure? failNext;
  Failure? readFailure;
  final _changes = StreamController<Result<AppSettings>>.broadcast();

  @override
  Stream<Result<AppSettings>> watch() async* {
    if (readFailure case final failure?) {
      yield Result.failure(failure);
      return;
    }
    yield Result.success(settings);
    yield* _changes.stream;
  }

  Future<Result<void>> _update(AppSettings updated) async {
    if (failNext case final failure?) {
      failNext = null;
      return Result.failure(failure);
    }
    settings = updated;
    _changes.add(Result.success(settings));
    return const Result.success(null);
  }

  @override
  Future<Result<void>> setUnits(UnitSystem units) =>
      _update(settings.copyWith(units: units));

  @override
  Future<Result<void>> setLanguage(AppLanguage language) =>
      _update(settings.copyWith(language: language));

  @override
  Future<Result<void>> setThemeMode(AppThemeMode themeMode) =>
      _update(settings.copyWith(themeMode: themeMode));

  @override
  Future<Result<void>> setVibrationOnArrival({required bool enabled}) =>
      _update(settings.copyWith(vibrationOnArrival: enabled));

  @override
  Future<Result<void>> setVibrationPattern(VibrationPattern pattern) =>
      _update(settings.copyWith(vibrationPattern: pattern));

  @override
  Future<Result<void>> setTouchFeedback({required bool enabled}) =>
      _update(settings.copyWith(touchFeedback: enabled));
}
