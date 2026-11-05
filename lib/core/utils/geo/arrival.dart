import 'dart:math' as math;

/// The user is at the point within this distance (mvp-scope.md §2.4).
const arrivalRadiusMeters = 20.0;

/// How much GPS uncertainty may widen [arrivalRadiusMeters]: with a weak
/// fix the user may stand at the point while the fix is off by tens of
/// meters, but a ±65 m fix must not announce arrival at 85 m.
const arrivalAccuracyAllowanceMeters = 10.0;

/// Whether [distanceMeters] counts as arrived for a fix of
/// [accuracyMeters]: the radius grows with the accuracy, up to the
/// allowance.
bool hasArrived({
  required double distanceMeters,
  required double accuracyMeters,
}) =>
    distanceMeters <=
    arrivalRadiusMeters +
        math.min(accuracyMeters, arrivalAccuracyAllowanceMeters);
