import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/location/data/datasources/location_datasource.dart';
import 'package:wayback/features/location/data/models/location_fix_model.dart';
import 'package:wayback/features/location/data/repositories/location_repository_impl.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

final _model = LocationFixModel(
  latitude: 55.75,
  longitude: 37.61,
  accuracyMeters: 8,
  timestamp: DateTime.utc(2026, 11, 5),
  altitudeMeters: 140,
);

final class _FakeDatasource implements LocationDatasource {
  LocalException? accessError;
  LocalException? fixError;
  LocationAccess access = LocationAccess.granted;
  bool settingsFail = true;
  int settingsOpened = 0;
  final fixes = StreamController<LocationFixModel>();

  @override
  Future<LocationAccess> checkAccess() async =>
      accessError == null ? access : throw accessError!;

  @override
  Future<LocationAccess> requestAccess() => checkAccess();

  @override
  Future<LocationFixModel> currentFix() async =>
      fixError == null ? _model : throw fixError!;

  @override
  Stream<LocationFixModel> watchFix() => fixes.stream;

  @override
  Future<void> openAppSettings() async {
    settingsOpened++;
    if (settingsFail) throw StateError('no activity');
  }

  @override
  Future<void> openLocationSettings() async {}
}

void main() {
  late _FakeDatasource datasource;
  late LocationRepositoryImpl repository;

  setUp(() {
    datasource = _FakeDatasource();
    repository = LocationRepositoryImpl(datasource);
  });

  group('approximate access', () {
    setUp(() {
      datasource
        ..access = LocationAccess.approximate
        ..settingsFail = false;
    });

    test('gives no fix to save', () async {
      final result = await repository.currentFix();

      expect(result.failureOrNull?.code, LocationErrorCodes.preciseRequired);
      expect(result.failureOrNull, isA<PermissionFailure>());
    });

    test('gives no fixes to navigate by, then recovers', () async {
      final first = await repository.watchFix().first;
      expect(first.failureOrNull?.code, LocationErrorCodes.preciseRequired);

      datasource.access = LocationAccess.granted;
      final next = repository.watchFix().first;
      await pumpEventQueue();
      datasource.fixes.add(_model);

      expect((await next).isSuccess, isTrue);
    });

    test('a request that changes nothing opens the settings', () async {
      final result = await repository.requestPreciseAccess();

      expect(result.valueOrNull, LocationAccess.approximate);
      expect(datasource.settingsOpened, 1);
    });

    test('a request that gives precise access stays in the app', () async {
      datasource.access = LocationAccess.granted;

      final result = await repository.requestPreciseAccess();

      expect(result.valueOrNull, LocationAccess.granted);
      expect(datasource.settingsOpened, 0);
    });
  });

  test('maps the model to an entity', () async {
    final result = await repository.currentFix();

    expect(
      result.valueOrNull,
      LocationFix(
        point: const GeoPoint(latitude: 55.75, longitude: 37.61),
        accuracyMeters: 8,
        timestamp: DateTime.utc(2026, 11, 5),
        altitudeMeters: 140,
      ),
    );
  });

  test('permission exception becomes a permission failure', () async {
    datasource.fixError = const PermissionException(
      code: LocationErrorCodes.permissionDenied,
    );

    expect(
      (await repository.currentFix()).failureOrNull,
      const PermissionFailure(code: LocationErrorCodes.permissionDenied),
    );
  });

  test('sensor exception becomes a sensor failure', () async {
    datasource.accessError = const SensorException(
      code: LocationErrorCodes.serviceDisabled,
    );

    expect(
      (await repository.checkAccess()).failureOrNull,
      const SensorFailure(code: LocationErrorCodes.serviceDisabled),
    );
  });

  test('a stream error becomes a failure and the stream goes on', () async {
    final results = <Result<LocationFix>>[];
    final sub = repository.watchFix().listen(results.add);

    datasource.fixes
      ..add(_model)
      ..addError(const SensorException(code: LocationErrorCodes.unavailable))
      ..add(_model);
    await pumpEventQueue();
    await sub.cancel();

    expect(results.map((r) => r.isSuccess), [true, false, true]);
    expect(
      results[1].failureOrNull,
      const SensorFailure(code: LocationErrorCodes.unavailable),
    );
  });

  test('settings that fail to open are a failure, not an exception', () async {
    final result = await repository.openAppSettings();

    expect(result.failureOrNull, isA<UnexpectedFailure>());
  });

  group('shared fix stream', () {
    test(
      'after a permission failure a new listener gets fresh fixes',
      () async {
        final datasource = _RestartingDatasource();
        final repository = LocationRepositoryImpl(datasource);
        final home = <Result<LocationFix>>[];
        final homeSub = repository.watchFix().listen(home.add);
        await pumpEventQueue();

        datasource.current.addError(
          const PermissionException(code: LocationErrorCodes.permissionDenied),
        );
        await pumpEventQueue();
        expect(home.single.failureOrNull, isA<PermissionFailure>());

        // The user allows access; the GPS widget listens again.
        final later = <Result<LocationFix>>[];
        final laterSub = repository.watchFix().listen(later.add);
        await pumpEventQueue();
        datasource.current.add(_model);
        await pumpEventQueue();

        expect(datasource.starts, 2);
        expect(later.single.isSuccess, isTrue, reason: 'no stale failure');
        expect(home.last.isSuccess, isTrue, reason: 'Home gets fixes too');
        await homeSub.cancel();
        await laterSub.cancel();
      },
    );

    test('a lost signal keeps the stream running', () async {
      final datasource = _RestartingDatasource();
      final repository = LocationRepositoryImpl(datasource);
      final results = <Result<LocationFix>>[];
      final sub = repository.watchFix().listen(results.add);
      await pumpEventQueue();

      datasource.current
        ..addError(const SensorException(code: LocationErrorCodes.unavailable))
        ..add(_model);
      await pumpEventQueue();
      await sub.cancel();

      expect(datasource.starts, 1);
      expect(results.map((r) => r.isSuccess), [false, true]);
    });
  });
}

/// Every watchFix() opens a new plugin stream, like the real plugin.
final class _RestartingDatasource implements LocationDatasource {
  late StreamController<LocationFixModel> current;
  int starts = 0;

  @override
  Stream<LocationFixModel> watchFix() {
    starts++;
    current = StreamController<LocationFixModel>();
    return current.stream;
  }

  @override
  Future<LocationAccess> checkAccess() async => LocationAccess.granted;

  @override
  Future<LocationAccess> requestAccess() async => LocationAccess.granted;

  @override
  Future<LocationFixModel> currentFix() async => _model;

  @override
  Future<void> openAppSettings() async {}

  @override
  Future<void> openLocationSettings() async {}
}
