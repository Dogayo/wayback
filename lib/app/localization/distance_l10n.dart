import 'package:wayback/app/localization/generated/app_localizations.dart';
import 'package:wayback/core/utils/geo/distance_formatter.dart';

extension DistanceL10n on AppLocalizations {
  /// Distance with a localized unit, e.g. `850 м` or `1,2 км`.
  String distance(double meters) {
    final formatted = formatDistance(meters, locale: localeName);
    return switch (formatted.unit) {
      DistanceUnit.meters => distanceMeters(formatted.value),
      DistanceUnit.kilometers => distanceKilometers(formatted.value),
    };
  }
}
