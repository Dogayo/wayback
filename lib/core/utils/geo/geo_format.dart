import 'package:wayback/core/utils/geo/geo_point.dart';

/// Decimal places of a shown coordinate: 5 is about 1 m on the ground.
const _coordinateDecimals = 5;

/// `55.75580, 37.61730`: latitude, longitude with a decimal point in every
/// locale, as maps and other apps read them.
String formatCoordinates(GeoPoint point) =>
    '${point.latitude.toStringAsFixed(_coordinateDecimals)}, '
    '${point.longitude.toStringAsFixed(_coordinateDecimals)}';
