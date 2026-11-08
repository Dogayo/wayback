import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/points/data/models/point_model.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';

extension SavedPointMapper on SavedPoint {
  PointModel toModel() => PointModel(
    id: id,
    name: name,
    type: type.name,
    latitude: position.latitude,
    longitude: position.longitude,
    altitudeMeters: altitudeMeters,
    createdAt: createdAt,
    isActive: isActive,
  );
}

extension PointModelMapper on PointModel {
  SavedPoint toEntity() => SavedPoint(
    id: id,
    name: name,
    type: PointType.values.asNameMap()[type] ?? PointType.generic,
    position: GeoPoint(latitude: latitude, longitude: longitude),
    altitudeMeters: altitudeMeters,
    createdAt: createdAt,
    isActive: isActive,
  );
}
