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
}
