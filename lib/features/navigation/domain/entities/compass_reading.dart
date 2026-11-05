/// Above this deviation, or when the platform cannot tell it, the compass
/// counts as unreliable and asks for calibration. Android reports 15°, 30°
/// or 45°, so only its lowest level (or none) fails.
const unreliableCompassAccuracyDegrees = 30.0;

/// Where the top of the device points.
final class CompassReading {
  const CompassReading({required this.headingDegrees, this.accuracyDegrees});

  /// Degrees clockwise from north, `0..360`.
  final double headingDegrees;

  /// Deviation, ± degrees; `null` when the platform cannot tell.
  final double? accuracyDegrees;

  bool get isUnreliable => switch (accuracyDegrees) {
    final accuracy? => accuracy > unreliableCompassAccuracyDegrees,
    null => true,
  };

  @override
  bool operator ==(Object other) =>
      other is CompassReading &&
      other.headingDegrees == headingDegrees &&
      other.accuracyDegrees == accuracyDegrees;

  @override
  int get hashCode => Object.hash(headingDegrees, accuracyDegrees);
}
