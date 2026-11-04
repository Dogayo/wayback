import 'package:wayback/core/utils/geo/geo_point.dart';

/// Above this horizontal accuracy the signal counts as weak: distance and
/// direction are shown with a warning instead of false confidence
/// (mvp-scope.md §2.1).
const weakSignalAccuracyMeters = 30.0;

/// One position reading from the device.
final class LocationFix {
  const LocationFix({
    required this.point,
    required this.accuracyMeters,
    required this.timestamp,
    this.altitudeMeters,
  });

  final GeoPoint point;

  /// Radius of 68% confidence around [point], meters.
  final double accuracyMeters;
  final DateTime timestamp;
  final double? altitudeMeters;

  bool get isWeakSignal => accuracyMeters > weakSignalAccuracyMeters;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationFix &&
          other.point == point &&
          other.accuracyMeters == accuracyMeters &&
          other.timestamp == timestamp &&
          other.altitudeMeters == altitudeMeters;

  @override
  int get hashCode =>
      Object.hash(point, accuracyMeters, timestamp, altitudeMeters);

  @override
  String toString() => 'LocationFix($point, ±$accuracyMeters m)';
}
