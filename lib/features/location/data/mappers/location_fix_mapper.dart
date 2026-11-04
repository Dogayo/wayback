import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/location/data/models/location_fix_model.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';

extension LocationFixMapper on LocationFixModel {
  LocationFix toEntity() => LocationFix(
    point: GeoPoint(latitude: latitude, longitude: longitude),
    accuracyMeters: accuracyMeters,
    timestamp: timestamp,
    altitudeMeters: altitudeMeters,
  );
}
