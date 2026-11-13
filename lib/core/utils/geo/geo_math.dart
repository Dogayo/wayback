import 'dart:math' as math;

import 'package:wayback/core/utils/geo/geo_point.dart';

/// Mean Earth radius (IUGG), meters.
const earthRadiusMeters = 6371008.8;

const _fullTurnDegrees = 360.0;
const _halfTurnDegrees = 180.0;

/// Great-circle distance between [from] and [to] in meters (haversine).
double distanceMeters(GeoPoint from, GeoPoint to) {
  final lat1 = _radians(from.latitude);
  final lat2 = _radians(to.latitude);
  final dLat = lat2 - lat1;
  final dLon = _radians(to.longitude - from.longitude);

  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2);
  // clamp guards asin against rounding just above 1 for antipodal points.
  return 2 * earthRadiusMeters * math.asin(math.sqrt(h.clamp(0.0, 1.0)));
}

/// Initial bearing from [from] to [to]: degrees clockwise from true north,
/// in `0..360`. Returns 0 when the points coincide.
double bearingDegrees(GeoPoint from, GeoPoint to) {
  final lat1 = _radians(from.latitude);
  final lat2 = _radians(to.latitude);
  final dLon = _radians(to.longitude - from.longitude);

  final y = math.sin(dLon) * math.cos(lat2);
  final x =
      math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
  return normalizeDegrees(_degrees(math.atan2(y, x)));
}

/// Angle to rotate the arrow so it points at the target while the device
/// faces [headingDegrees]: `bearing - heading`, in `0..360`.
double arrowRotationDegrees({
  required double bearingDegrees,
  required double headingDegrees,
}) => normalizeDegrees(bearingDegrees - headingDegrees);

/// Signed shortest turn from [fromDegrees] to [toDegrees], in `-180..180`.
/// `359 → 1` gives `+2`, not `-358`.
double shortestArcDegrees(double fromDegrees, double toDegrees) {
  final delta = normalizeDegrees(toDegrees - fromDegrees);
  return delta > _halfTurnDegrees ? delta - _fullTurnDegrees : delta;
}

/// Next value for an animated, unbounded rotation angle: moves [current]
/// toward [targetDegrees] along the shortest arc. The result is not wrapped,
/// so a tween from [current] never spins through the long way round.
double continuousRotationDegrees(double current, double targetDegrees) =>
    current + shortestArcDegrees(current, targetDegrees);

/// Wraps any angle into `0..360` (360 itself becomes 0).
double normalizeDegrees(double degrees) {
  final wrapped = degrees % _fullTurnDegrees;
  return wrapped == _fullTurnDegrees ? 0 : wrapped;
}

double _radians(double degrees) => degrees * math.pi / _halfTurnDegrees;

double _degrees(double radians) => radians * _halfTurnDegrees / math.pi;

/// One of the eight compass sectors a bearing can fall into.
enum CardinalDirection {
  north,
  northEast,
  east,
  southEast,
  south,
  southWest,
  west,
  northWest,
}

/// The sector [degrees] falls into, measured clockwise from true north.
/// Each sector spans 45° and is centred on its own direction, so north runs
/// from 337.5° to 22.5°.
CardinalDirection cardinalDirection(double degrees) {
  final sector = ((normalizeDegrees(degrees) + 22.5) ~/ 45) % 8;
  return CardinalDirection.values[sector];
}
