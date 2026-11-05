import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/features/points/data/datasources/shared_preferences_points_datasource.dart';
import 'package:wayback/features/points/data/mappers/point_mapper.dart';
import 'package:wayback/features/points/data/models/point_model.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

final _model = PointModel(
  id: 'a',
  name: 'Машина',
  type: 'car',
  latitude: 55.75,
  longitude: 37.61,
  altitudeMeters: 140,
  createdAt: DateTime.utc(2026, 11, 5, 12),
  isActive: false,
);

Future<SharedPreferencesPointsDatasource> _datasource([
  Map<String, Object> values = const {},
]) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferencesPointsDatasource(
    await SharedPreferences.getInstance(),
  );
}

void main() {
  test('nothing stored reads as no points', () async {
    expect(await (await _datasource()).readAll(), isEmpty);
  });

  test('points survive a write and a new instance', () async {
    await (await _datasource()).writeAll([_model]);
    final stored = (await SharedPreferences.getInstance()).getString(
      SharedPreferencesPointsDatasource.storageKey,
    )!;

    final read = await (await _datasource({
      SharedPreferencesPointsDatasource.storageKey: stored,
    })).readAll();

    final point = read.single.toEntity();
    expect(point.name, 'Машина');
    expect(point.type, PointType.car);
    expect(point.altitudeMeters, 140);
    expect(point.isActive, isFalse);
    expect(point.createdAt, DateTime.utc(2026, 11, 5, 12));
  });

  test('an unknown type from a newer version reads as generic', () {
    final model = PointModel.fromJson({
      ..._model.toJson(),
      'type': 'helicopter',
    });
    expect(model.toEntity().type, PointType.generic);
  });

  test('a corrupted value is a read failure, not a crash', () async {
    final datasource = await _datasource({
      SharedPreferencesPointsDatasource.storageKey: '{not json',
    });

    expect(
      datasource.readAll,
      throwsA(
        isA<StorageException>().having(
          (e) => e.code,
          'code',
          PointsErrorCodes.storageReadFailed,
        ),
      ),
    );
  });
}
