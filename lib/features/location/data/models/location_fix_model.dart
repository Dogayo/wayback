/// Position as the datasource reports it, before it becomes a domain entity.
final class LocationFixModel {
  const LocationFixModel({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.timestamp,
    this.altitudeMeters,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime timestamp;
  final double? altitudeMeters;
}
