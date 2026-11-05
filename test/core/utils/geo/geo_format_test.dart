import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/utils/geo/geo_format.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';

void main() {
  test('coordinates with five decimals and a decimal point', () {
    expect(
      formatCoordinates(const GeoPoint(latitude: 55.7558, longitude: 37.6173)),
      '55.75580, 37.61730',
    );
    expect(
      formatCoordinates(
        const GeoPoint(latitude: -33.86882, longitude: 151.2093),
      ),
      '-33.86882, 151.20930',
    );
  });
}
