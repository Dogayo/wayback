import 'package:wayback/features/points/domain/entities/saved_point.dart';

/// How far the compass can be trusted right now.
enum CompassStatus {
  ok,

  /// Readings come but need calibration; the arrow is approximate.
  unreliable,

  /// No compass, or it failed: distance only, no arrow.
  unavailable,
}

/// Everything the navigation screen shows for one moment.
final class NavigationGuidance {
  const NavigationGuidance({
    required this.point,
    required this.distanceMeters,
    required this.accuracyMeters,
    required this.weakSignal,
    required this.arrived,
    required this.compass,
    this.arrowDegrees,
  });

  final SavedPoint point;
  final double distanceMeters;
  final double accuracyMeters;
  final bool weakSignal;
  final bool arrived;
  final CompassStatus compass;

  /// Arrow rotation, degrees, not wrapped: it changes along the shortest arc
  /// from the previous value, so the arrow never spins round at north.
  /// `null` while there is no compass.
  final double? arrowDegrees;

  @override
  bool operator ==(Object other) =>
      other is NavigationGuidance &&
      other.point == point &&
      other.distanceMeters == distanceMeters &&
      other.accuracyMeters == accuracyMeters &&
      other.weakSignal == weakSignal &&
      other.arrived == arrived &&
      other.compass == compass &&
      other.arrowDegrees == arrowDegrees;

  @override
  int get hashCode => Object.hash(
    point,
    distanceMeters,
    accuracyMeters,
    weakSignal,
    arrived,
    compass,
    arrowDegrees,
  );
}
