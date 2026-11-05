import 'dart:async';

import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

SavedPoint savedPoint(
  String id, {
  String? name,
  PointType type = PointType.car,
  bool active = true,
  GeoPoint position = const GeoPoint(latitude: 55.75, longitude: 37.61),
  DateTime? createdAt,
}) => SavedPoint(
  id: id,
  name: name ?? 'Point $id',
  type: type,
  position: position,
  createdAt: createdAt ?? DateTime.utc(2026, 11, 5),
  isActive: active,
);

/// In-memory points; [failNext] makes the next call fail with it.
final class FakePointsRepository implements PointsRepository {
  FakePointsRepository([List<SavedPoint> points = const []])
    : points = [...points];

  final List<SavedPoint> points;
  Failure? failNext;
  Failure? readFailure;
  final _changes = StreamController<Result<List<SavedPoint>>>.broadcast();
  var _ids = 0;

  void _publish() => _changes.add(Result.success(List.of(points)));

  Result<T>? _failure<T>() {
    final failure = failNext;
    failNext = null;
    return failure == null ? null : Result.failure(failure);
  }

  @override
  Stream<Result<List<SavedPoint>>> watchAll() async* {
    if (readFailure case final failure?) {
      yield Result.failure(failure);
      return;
    }
    yield Result.success(List.of(points));
    yield* _changes.stream;
  }

  @override
  Future<Result<SavedPoint>> getById(String id) async =>
      _failure() ??
      Result.success(points.firstWhere((point) => point.id == id));

  @override
  Future<Result<SavedPoint>> create({
    required String name,
    required PointType type,
    required GeoPoint position,
    double? altitudeMeters,
  }) async {
    if (_failure<SavedPoint>() case final failure?) return failure;
    final point = SavedPoint(
      id: 'new-${_ids++}',
      name: name,
      type: type,
      position: position,
      createdAt: DateTime.utc(2026, 11, 5, 12),
      altitudeMeters: altitudeMeters,
    );
    points.insert(0, point);
    _publish();
    return Result.success(point);
  }

  Future<Result<SavedPoint>> _change(
    String id,
    SavedPoint Function(SavedPoint point) change,
  ) async {
    if (_failure<SavedPoint>() case final failure?) return failure;
    final index = points.indexWhere((point) => point.id == id);
    points[index] = change(points[index]);
    _publish();
    return Result.success(points[index]);
  }

  @override
  Future<Result<SavedPoint>> rename(String id, String name) =>
      _change(id, (point) => point.copyWith(name: name));

  @override
  Future<Result<SavedPoint>> setActive(String id, {required bool active}) =>
      _change(id, (point) => point.copyWith(isActive: active));

  @override
  Future<Result<void>> delete(String id) async {
    if (_failure<void>() case final failure?) return failure;
    points.removeWhere((point) => point.id == id);
    _publish();
    return const Result.success(null);
  }
}
