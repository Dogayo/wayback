import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/features/points/data/datasources/points_local_datasource.dart';
import 'package:wayback/features/points/data/models/point_model.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

/// All points as one JSON list under a versioned key: a hundred points are
/// a few kilobytes, and one write keeps the list consistent.
final class SharedPreferencesPointsDatasource implements PointsLocalDatasource {
  const SharedPreferencesPointsDatasource(this._preferences);

  static const storageKey = 'points.v1';

  final SharedPreferences _preferences;

  @override
  Future<List<PointModel>> readAll() async {
    final raw = _preferences.getString(storageKey);
    if (raw == null) return const [];
    try {
      return [
        for (final item in jsonDecode(raw) as List<dynamic>)
          PointModel.fromJson(item as Map<String, dynamic>),
      ];
    } on Object catch (error, stackTrace) {
      throw StorageException(
        code: PointsErrorCodes.storageReadFailed,
        description: 'Stored points are not readable',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> writeAll(List<PointModel> points) async {
    final bool saved;
    try {
      saved = await _preferences.setString(
        storageKey,
        jsonEncode([for (final point in points) point.toJson()]),
      );
    } on Object catch (error, stackTrace) {
      throw StorageException(
        code: PointsErrorCodes.storageWriteFailed,
        cause: error,
        stackTrace: stackTrace,
      );
    }
    if (!saved) {
      throw const StorageException(
        code: PointsErrorCodes.storageWriteFailed,
        description: 'SharedPreferences refused the write',
      );
    }
  }
}
