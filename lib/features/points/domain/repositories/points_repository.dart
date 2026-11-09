import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';

/// Failure codes [PointsRepository] can return (architecture.md §4.2).
abstract final class PointsErrorCodes {
  static const storageReadFailed = 'points_storage_read_failed';
  static const storageWriteFailed = 'points_storage_write_failed';
  static const notFound = 'points_not_found';
}

/// Every method returns a [Result]; none of them throws.
abstract interface class PointsRepository {
  /// Current points, newest first, then every change.
  Stream<Result<List<SavedPoint>>> watchAll();

  Future<Result<SavedPoint>> getById(String id);

  /// Saves a new point; it is active right away (SCREENS.md §5).
  Future<Result<SavedPoint>> create({
    required String name,
    required PointType type,
    required GeoPoint position,
    double? altitudeMeters,
  });

  /// Changes what the user chose for a point: its name and type.
  Future<Result<SavedPoint>> edit(
    String id, {
    required String name,
    required PointType type,
  });

  Future<Result<SavedPoint>> setActive(String id, {required bool active});

  Future<Result<void>> delete(String id);

  /// Puts [point] back exactly as it was, with its id and date: after a
  /// delete, or over a later change to the same point.
  Future<Result<SavedPoint>> restore(SavedPoint point);
}
