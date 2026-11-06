import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/utils/geo/arrival.dart';

void main() {
  test('arrived within the radius with a good fix', () {
    expect(hasArrived(distanceMeters: 19, accuracyMeters: 5), isTrue);
    expect(hasArrived(distanceMeters: 30, accuracyMeters: 5), isFalse);
  });

  test('a weaker fix widens the radius, but only up to the allowance', () {
    expect(hasArrived(distanceMeters: 28, accuracyMeters: 9), isTrue);
    expect(
      hasArrived(
        distanceMeters:
            arrivalRadiusMeters + arrivalAccuracyAllowanceMeters + 1,
        accuracyMeters: 65,
      ),
      isFalse,
    );
  });

  test('a user who has arrived leaves only past the exit margin', () {
    // The field check: in at 22.5 m, out at 26.9 m with a ±3 m fix.
    expect(hasArrived(distanceMeters: 26.9, accuracyMeters: 3), isFalse);
    expect(
      hasArrived(distanceMeters: 26.9, accuracyMeters: 3, wasArrived: true),
      isTrue,
    );
    expect(
      hasArrived(distanceMeters: 39, accuracyMeters: 3, wasArrived: true),
      isFalse,
    );
  });
}
