import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/points/data/datasources/shared_preferences_points_datasource.dart';
import 'package:wayback/features/points/data/repositories/points_repository_impl.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

const _here = GeoPoint(latitude: 55.75, longitude: 37.61);

void main() {
  late PointsRepositoryImpl repository;
  var clock = DateTime.utc(2026, 11, 5, 10);
  var ids = 0;

  Future<PointsRepositoryImpl> build([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return PointsRepositoryImpl(
      SharedPreferencesPointsDatasource(await SharedPreferences.getInstance()),
      now: () => clock = clock.add(const Duration(minutes: 1)),
      newId: () => 'id-${ids++}',
    );
  }

  setUp(() async => repository = await build());

  Future<SavedPoint> create(String name) async => (await repository.create(
    name: name,
    type: PointType.car,
    position: _here,
  )).valueOrNull!;

  test('a new point is active and listed newest first', () async {
    await create('Первая');
    final second = await create('Вторая');

    final list = (await repository.watchAll().first).valueOrNull!;
    expect(second.isActive, isTrue);
    expect(list.map((p) => p.name), ['Вторая', 'Первая']);
  });

  test('points survive a restart', () async {
    await create('Машина');
    final stored = (await SharedPreferences.getInstance()).getString(
      SharedPreferencesPointsDatasource.storageKey,
    )!;

    final restarted = await build({
      SharedPreferencesPointsDatasource.storageKey: stored,
    });

    final list = (await restarted.watchAll().first).valueOrNull!;
    expect(list.single.name, 'Машина');
  });

  test('watchers see every change', () async {
    final seen = <List<String>>[];
    final sub = repository.watchAll().listen(
      (result) => seen.add([for (final p in result.valueOrNull!) p.name]),
    );
    await pumpEventQueue();

    final point = await create('Машина');
    await repository.edit(point.id, name: 'Машина у леса', type: point.type);
    await repository.delete(point.id);
    await pumpEventQueue();
    await sub.cancel();

    expect(seen, [
      <String>[],
      ['Машина'],
      ['Машина у леса'],
      <String>[],
    ]);
  });

  test('activity can be switched off and on', () async {
    final point = await create('Машина');

    final off = await repository.setActive(point.id, active: false);
    final on = await repository.setActive(point.id, active: true);

    expect(off.valueOrNull!.isActive, isFalse);
    expect(on.valueOrNull!.isActive, isTrue);
  });

  test('a deleted point comes back as it was and in its place', () async {
    await create('Первая');
    final second = await create('Вторая');
    await create('Третья');
    await repository.setActive(second.id, active: false);
    final deleted = (await repository.getById(second.id)).valueOrNull!;

    await repository.delete(second.id);
    await repository.restore(deleted);

    final all = (await repository.watchAll().first).valueOrNull!;
    expect(all.map((point) => point.name), ['Третья', 'Вторая', 'Первая']);
    expect(all[1], deleted);
  });

  test('restoring over a later change replaces the point', () async {
    final point = await create('Первая');
    await repository.setActive(point.id, active: false);

    await repository.restore(point);

    final all = (await repository.watchAll().first).valueOrNull!;
    expect(all.single, point);
  });

  test('a missing point is a not-found failure', () async {
    for (final result in [
      await repository.getById('nope'),
      await repository.edit('nope', name: 'x', type: PointType.generic),
      await repository.delete('nope'),
    ]) {
      expect(
        result.failureOrNull,
        isA<NotFoundFailure>().having(
          (f) => f.code,
          'code',
          PointsErrorCodes.notFound,
        ),
      );
    }
  });

  test('unreadable storage is a failure in the stream', () async {
    repository = await build({
      SharedPreferencesPointsDatasource.storageKey: 'broken',
    });

    final first = await repository.watchAll().first;
    expect(first, isA<Failed<List<SavedPoint>>>());
    expect(first.failureOrNull!.code, PointsErrorCodes.storageReadFailed);
  });
}
