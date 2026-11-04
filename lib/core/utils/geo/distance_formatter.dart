import 'package:intl/intl.dart';

/// Below this many meters a distance is shown in meters, otherwise in
/// kilometers (mvp-scope.md §2.3).
const metersPerKilometer = 1000;

enum DistanceUnit { meters, kilometers }

/// A distance ready for display: the number is formatted for the locale,
/// the unit label comes from l10n in the view.
final class FormattedDistance {
  const FormattedDistance({required this.value, required this.unit});

  final String value;
  final DistanceUnit unit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormattedDistance && other.value == value && other.unit == unit;

  @override
  int get hashCode => Object.hash(value, unit);

  @override
  String toString() => 'FormattedDistance($value ${unit.name})';
}

/// Whole meters below 1000 m, kilometers with one decimal from there on.
///
/// Rounding happens before the unit is chosen, so 999.6 m becomes
/// `1.0 km` rather than `1000 m`.
FormattedDistance formatDistance(double meters, {required String locale}) {
  final roundedMeters = meters.round();
  if (roundedMeters < metersPerKilometer) {
    return FormattedDistance(
      value: NumberFormat.decimalPattern(locale).format(roundedMeters),
      unit: DistanceUnit.meters,
    );
  }
  return FormattedDistance(
    value: NumberFormat('#,##0.0', locale).format(meters / metersPerKilometer),
    unit: DistanceUnit.kilometers,
  );
}
