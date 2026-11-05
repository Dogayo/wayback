import 'package:wayback/features/points/data/models/point_model.dart';

/// Throws `StorageException` with a `PointsErrorCodes` code.
abstract interface class PointsLocalDatasource {
  Future<List<PointModel>> readAll();

  Future<void> writeAll(List<PointModel> points);
}
