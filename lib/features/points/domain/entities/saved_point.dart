import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';

final class SavedPoint {
  const SavedPoint({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    required this.createdAt,
    this.altitudeMeters,
    this.isActive = true,
  });

  final String id;
  final String name;
  final PointType type;
  final GeoPoint position;
  final DateTime createdAt;
  final double? altitudeMeters;

  /// Shown on Home and offered for navigation; any number can be active.
  final bool isActive;

  SavedPoint copyWith({String? name, PointType? type, bool? isActive}) =>
      SavedPoint(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        position: position,
        createdAt: createdAt,
        altitudeMeters: altitudeMeters,
        isActive: isActive ?? this.isActive,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedPoint &&
          other.id == id &&
          other.name == name &&
          other.type == type &&
          other.position == position &&
          other.createdAt == createdAt &&
          other.altitudeMeters == altitudeMeters &&
          other.isActive == isActive;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    position,
    createdAt,
    altitudeMeters,
    isActive,
  );

  @override
  String toString() => 'SavedPoint($id, $name, ${type.name})';
}
