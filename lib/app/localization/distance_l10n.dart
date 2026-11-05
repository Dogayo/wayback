import 'package:wayback/app/localization/generated/app_localizations.dart';
import 'package:wayback/core/utils/geo/distance_formatter.dart';

export 'package:wayback/core/utils/geo/distance_formatter.dart' show UnitSystem;

extension DistanceL10n on AppLocalizations {
  /// Distance with a localized unit and a non-breaking space, e.g. `850 м`
  /// or `0,4 ми`.
  String distance(double meters, {UnitSystem units = UnitSystem.metric}) {
    final formatted = formatDistance(meters, locale: localeName, system: units);
    return switch (formatted.unit) {
      DistanceUnit.meters => distanceMeters(formatted.value),
      DistanceUnit.kilometers => distanceKilometers(formatted.value),
      DistanceUnit.feet => distanceFeet(formatted.value),
      DistanceUnit.miles => distanceMiles(formatted.value),
    };
  }

  /// [meters], or a dash while the distance is not known yet.
  String distanceOrUnknown(
    double? meters, {
    UnitSystem units = UnitSystem.metric,
  }) => meters == null ? distanceUnknown : distance(meters, units: units);

  /// GPS accuracy as `±8 м` or `±26 фт`: whole units, never kilometers or
  /// miles (docs/copy.md §9).
  String accuracy(double meters, {UnitSystem units = UnitSystem.metric}) {
    final formatted = formatAccuracy(meters, locale: localeName, system: units);
    return switch (formatted.unit) {
      DistanceUnit.feet => accuracyValueFeet(formatted.value),
      _ => accuracyValue(formatted.value),
    };
  }
}
