import 'dart:async';
import 'dart:math';

import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/result/result_handler.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/points/data/datasources/points_local_datasource.dart';
import 'package:wayback/features/points/data/mappers/point_mapper.dart';
import 'package:wayback/features/points/data/models/point_model.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

final class PointsRepositoryImpl
    with ResultHandler
    implements PointsRepository {
  PointsRepositoryImpl(
    this._datasource, {
    this.resultOptions = const ResultHandlerOptions(),
    DateTime Function()? now,
    String Function()? newId,
  }) : _now = now ?? DateTime.now,
       _newId = newId ?? _randomId;

  final PointsLocalDatasource _datasource;
  final DateTime Function() _now;
  final String Function() _newId;
  final _changes = StreamController<List<SavedPoint>>.broadcast();

  /// Last list read or written; the datasource is read once.
  List<PointModel>? _cache;

  @override
  final ResultHandlerOptions resultOptions;

  @override
  Stream<Result<List<SavedPoint>>> watchAll() => handleStream(_watch());

  @override
  Future<Result<SavedPoint>> getById(String id) =>
      handle(() async => _find(await _models(), id).toEntity());

  @override
  Future<Result<SavedPoint>> create({
    required String name,
    required PointType type,
    required GeoPoint position,
    double? altitudeMeters,
  }) => handle(() async {
    final point = PointModel(
      id: _newId(),
      name: name,
      type: type.name,
      latitude: position.latitude,
      longitude: position.longitude,
      altitudeMeters: altitudeMeters,
      createdAt: _now(),
      isActive: true,
    );
    await _save([point, ...await _models()]);
    return point.toEntity();
  });

  @override
  Future<Result<SavedPoint>> rename(String id, String name) =>
      handle(() => _update(id, (point) => point.copyWith(name: name)));

  @override
  Future<Result<SavedPoint>> setActive(String id, {required bool active}) =>
      handle(() => _update(id, (point) => point.copyWith(isActive: active)));

  @override
  Future<Result<void>> delete(String id) => handle(() async {
    final points = await _models();
    final target = _find(points, id);
    await _save([...points]..remove(target));
  });

  @override
  Future<Result<SavedPoint>> restore(SavedPoint point) => handle(() async {
    await _save([
      for (final other in await _models())
        if (other.id != point.id) other,
      point.toModel(),
    ]);
    return point;
  });

  Stream<List<SavedPoint>> _watch() async* {
    yield _entities(await _models());
    yield* _changes.stream;
  }

  Future<SavedPoint> _update(
    String id,
    PointModel Function(PointModel point) change,
  ) async {
    final points = await _models();
    final updated = change(_find(points, id));
    await _save([
      for (final point in points)
        if (point.id == id) updated else point,
    ]);
    return updated.toEntity();
  }

  Future<List<PointModel>> _models() async =>
      _cache ??= await _datasource.readAll();

  Future<void> _save(List<PointModel> points) async {
    await _datasource.writeAll(points);
    _cache = points;
    _changes.add(_entities(points));
  }

  static PointModel _find(List<PointModel> points, String id) =>
      points.firstWhere(
        (point) => point.id == id,
        orElse: () => throw NotFoundException(
          code: PointsErrorCodes.notFound,
          description: 'No point with id $id',
        ),
      );

  static List<SavedPoint> _entities(List<PointModel> points) =>
      [for (final point in points) point.toEntity()]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  static final _random = Random.secure();

  static String _randomId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
      '-${_random.nextInt(1 << 32).toRadixString(36)}';
}
