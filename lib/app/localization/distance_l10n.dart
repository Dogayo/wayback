import 'package:wayback/app/localization/generated/app_localizations.dart';
import 'package:wayback/core/utils/geo/distance_formatter.dart';

extension DistanceL10n on AppLocalizations {
  /// Distance with a localized unit and a non-breaking space, e.g. `850 м`.
  String distance(double meters) {
    final formatted = formatDistance(meters, locale: localeName);
    return switch (formatted.unit) {
      DistanceUnit.meters => distanceMeters(formatted.value),
      DistanceUnit.kilometers => distanceKilometers(formatted.value),
    };
  }

  /// [meters], or a dash while the distance is not known yet.
  String distanceOrUnknown(double? meters) =>
      meters == null ? distanceUnknown : distance(meters);

  /// GPS accuracy as `±8 м`: whole meters, never kilometers (docs/copy.md §9).
  String accuracy(double meters) => accuracyValue('${meters.round()}');
}
