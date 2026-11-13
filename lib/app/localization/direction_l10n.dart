import 'package:wayback/app/localization/generated/app_localizations.dart';
import 'package:wayback/core/utils/geo/geo_math.dart';

export 'package:wayback/core/utils/geo/geo_math.dart' show CardinalDirection;

extension DirectionL10n on AppLocalizations {
  /// The short name of a compass sector, e.g. `СЗ` or `NW`.
  String cardinal(CardinalDirection direction) => switch (direction) {
    CardinalDirection.north => directionShortNorth,
    CardinalDirection.northEast => directionShortNorthEast,
    CardinalDirection.east => directionShortEast,
    CardinalDirection.southEast => directionShortSouthEast,
    CardinalDirection.south => directionShortSouth,
    CardinalDirection.southWest => directionShortSouthWest,
    CardinalDirection.west => directionShortWest,
    CardinalDirection.northWest => directionShortNorthWest,
  };

  /// Which way the point lies, for the background notice: `СЗ · 320°`.
  /// It is read against north, not against the way the phone is held, so it
  /// stays true between the rare updates a Live Activity gets.
  String noticeDirection(double bearingDegrees) {
    final degrees = normalizeDegrees(bearingDegrees).round() % 360;
    return navigateNoticeDirection(
      cardinal(cardinalDirection(bearingDegrees)),
      degrees,
    );
  }
}
