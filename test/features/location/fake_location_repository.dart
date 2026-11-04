import 'dart:async';

import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';

LocationFix fixWithAccuracy(double meters) => LocationFix(
  point: const GeoPoint(latitude: 55.7558, longitude: 37.6173),
  accuracyMeters: meters,
  timestamp: DateTime.utc(2026, 11, 5, 12),
);

final class FakeLocationRepository implements LocationRepository {
  FakeLocationRepository({
    this.access = const Result.success(LocationAccess.granted),
    LocationAccess? afterRequest,
  }) : afterRequest = afterRequest ?? LocationAccess.granted;

  Result<LocationAccess> access;
  LocationAccess afterRequest;
  final fixes = StreamController<Result<LocationFix>>.broadcast();
  int requests = 0;
  final opened = <String>[];

  @override
  Future<Result<LocationAccess>> checkAccess() async => access;

  @override
  Future<Result<LocationAccess>> requestAccess() async {
    requests++;
    return access = Result.success(afterRequest);
  }

  @override
  Future<Result<LocationFix>> currentFix() async =>
      Result.success(fixWithAccuracy(8));

  @override
  Stream<Result<LocationFix>> watchFix() => fixes.stream;

  @override
  Future<Result<void>> openAppSettings() async {
    opened.add('app');
    return const Result.success(null);
  }

  @override
  Future<Result<void>> openLocationSettings() async {
    opened.add('location');
    return const Result.success(null);
  }
}
