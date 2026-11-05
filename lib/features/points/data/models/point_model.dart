/// Stored form of a point; the JSON layout is versioned by the storage key.
final class PointModel {
  const PointModel({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.isActive,
    this.altitudeMeters,
  });

  factory PointModel.fromJson(Map<String, dynamic> json) => PointModel(
    id: json['id'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    latitude: (json['lat'] as num).toDouble(),
    longitude: (json['lon'] as num).toDouble(),
    altitudeMeters: (json['alt'] as num?)?.toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    isActive: json['active'] as bool? ?? true,
  );

  final String id;
  final String name;

  /// `PointType.name`; kept as a string so an unknown future type does not
  /// break reading.
  final String type;
  final double latitude;
  final double longitude;
  final double? altitudeMeters;
  final DateTime createdAt;
  final bool isActive;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'lat': latitude,
    'lon': longitude,
    if (altitudeMeters != null) 'alt': altitudeMeters,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'active': isActive,
  };

  PointModel copyWith({String? name, bool? isActive}) => PointModel(
    id: id,
    name: name ?? this.name,
    type: type,
    latitude: latitude,
    longitude: longitude,
    altitudeMeters: altitudeMeters,
    createdAt: createdAt,
    isActive: isActive ?? this.isActive,
  );
}
