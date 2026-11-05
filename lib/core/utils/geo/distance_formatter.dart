import 'package:intl/intl.dart';

/// Below this many meters a distance is shown in meters, otherwise in
/// kilometers (mvp-scope.md §2.3).
const metersPerKilometer = 1000;

/// Meters in one foot and feet in one mile, by definition.
const metersPerFoot = 0.3048;
const feetPerMile = 5280;

/// Below this many miles an imperial distance is shown in feet: further out
/// feet run to four digits and are hard to read at a glance (docs/copy.md §9).
const imperialFeetLimitMiles = 0.1;

/// How distances are measured; chosen in the settings.
enum UnitSystem { metric, imperial }

enum DistanceUnit { meters, kilometers, feet, miles }

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

/// Metric: whole meters below 1000 m, kilometers with one decimal from
/// there on. Imperial: whole feet below 0.1 mile, miles with one decimal
/// from there on.
///
/// Rounding happens before the unit is chosen, so 999.6 m becomes `1.0 km`
/// rather than `1000 m`, and 527.8 ft becomes `0.1 mi`.
FormattedDistance formatDistance(
  double meters, {
  required String locale,
  UnitSystem system = UnitSystem.metric,
}) {
  final (small, smallUnit, largeUnit, perLarge) = switch (system) {
    UnitSystem.metric => (
      meters,
      DistanceUnit.meters,
      DistanceUnit.kilometers,
      metersPerKilometer.toDouble(),
    ),
    UnitSystem.imperial => (
      meters / metersPerFoot,
      DistanceUnit.feet,
      DistanceUnit.miles,
      feetPerMile.toDouble(),
    ),
  };
  final limit = switch (system) {
    UnitSystem.metric => perLarge,
    UnitSystem.imperial => perLarge * imperialFeetLimitMiles,
  };
  if (small.round() < limit) {
    return FormattedDistance(
      value: NumberFormat.decimalPattern(locale).format(small.round()),
      unit: smallUnit,
    );
  }
  return FormattedDistance(
    value: NumberFormat('#,##0.0', locale).format(small / perLarge),
    unit: largeUnit,
  );
}

/// GPS accuracy: whole meters or whole feet, never the larger unit.
FormattedDistance formatAccuracy(
  double meters, {
  required String locale,
  UnitSystem system = UnitSystem.metric,
}) => switch (system) {
  UnitSystem.metric => FormattedDistance(
    value: NumberFormat.decimalPattern(locale).format(meters.round()),
    unit: DistanceUnit.meters,
  ),
  UnitSystem.imperial => FormattedDistance(
    value: NumberFormat.decimalPattern(
      locale,
    ).format((meters / metersPerFoot).round()),
    unit: DistanceUnit.feet,
  ),
};
