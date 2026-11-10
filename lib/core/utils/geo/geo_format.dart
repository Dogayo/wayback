import 'package:wayback/core/utils/geo/geo_point.dart';

/// Decimal places of a shown coordinate: 5 is about 1 m on the ground.
const _coordinateDecimals = 5;

/// `56.5`: a coordinate with no more digits than it has, up to the same
/// precision, so that a rough one does not look exact.
String formatDegrees(double degrees) => degrees
    .toStringAsFixed(_coordinateDecimals)
    .replaceFirst(RegExp(r'\.?0+$'), '');

/// `56.5, 85`: latitude, longitude, each as in [formatDegrees].
String formatShortCoordinates(GeoPoint point) =>
    '${formatDegrees(point.latitude)}, ${formatDegrees(point.longitude)}';

/// `55.75580, 37.61730`: latitude, longitude with a decimal point in every
/// locale, as maps and other apps read them.
String formatCoordinates(GeoPoint point) =>
    '${point.latitude.toStringAsFixed(_coordinateDecimals)}, '
    '${point.longitude.toStringAsFixed(_coordinateDecimals)}';
