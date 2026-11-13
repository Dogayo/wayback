import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/utils/geo/geo_math.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';

const _origin = GeoPoint(latitude: 0, longitude: 0);

void main() {
  group('distanceMeters', () {
    test('is zero for the same point', () {
      expect(distanceMeters(_origin, _origin), 0);
    });

    test('one degree along a meridian is ~111.2 km', () {
      const north = GeoPoint(latitude: 1, longitude: 0);
      expect(distanceMeters(_origin, north), closeTo(111195, 1));
    });

    test('Moscow to Saint Petersburg is ~634 km', () {
      const moscow = GeoPoint(latitude: 55.7558, longitude: 37.6173);
      const spb = GeoPoint(latitude: 59.9343, longitude: 30.3351);
      expect(distanceMeters(moscow, spb), closeTo(634000, 2000));
    });

    test('is symmetric', () {
      const a = GeoPoint(latitude: 48.8566, longitude: 2.3522);
      const b = GeoPoint(latitude: 51.5074, longitude: -0.1278);
      expect(distanceMeters(a, b), closeTo(distanceMeters(b, a), 1e-6));
    });

    test('short walking distances stay accurate', () {
      // ~0.0001° of latitude ≈ 11.1 m
      const a = GeoPoint(latitude: 55.75, longitude: 37.61);
      const b = GeoPoint(latitude: 55.7501, longitude: 37.61);
      expect(distanceMeters(a, b), closeTo(11.12, 0.01));
    });

    test('antipodal points give half the circumference', () {
      const antipode = GeoPoint(latitude: 0, longitude: 180);
      expect(
        distanceMeters(_origin, antipode),
        closeTo(earthRadiusMeters * 3.141592653589793, 1),
      );
    });
  });

  group('bearingDegrees', () {
    final cases = <String, (GeoPoint, double)>{
      'north': (const GeoPoint(latitude: 1, longitude: 0), 0),
      'east': (const GeoPoint(latitude: 0, longitude: 1), 90),
      'south': (const GeoPoint(latitude: -1, longitude: 0), 180),
      'west': (const GeoPoint(latitude: 0, longitude: -1), 270),
    };

    for (final MapEntry(key: name, value: (target, expected))
        in cases.entries) {
      test('due $name is $expected°', () {
        expect(bearingDegrees(_origin, target), closeTo(expected, 1e-9));
      });
    }

    test('north-east diagonal near the equator is ~45°', () {
      const target = GeoPoint(latitude: 0.001, longitude: 0.001);
      expect(bearingDegrees(_origin, target), closeTo(45, 0.01));
    });

    test('is 0 for the same point', () {
      expect(bearingDegrees(_origin, _origin), 0);
    });

    test('is always within 0..360', () {
      const from = GeoPoint(latitude: 55.75, longitude: 37.61);
      for (var lon = -180.0; lon <= 180; lon += 15) {
        final bearing = bearingDegrees(
          from,
          GeoPoint(latitude: -30, longitude: lon),
        );
        expect(bearing, inInclusiveRange(0, 360));
        expect(bearing, isNot(360));
      }
    });
  });

  group('arrowRotationDegrees', () {
    test('is bearing minus heading', () {
      expect(arrowRotationDegrees(bearingDegrees: 90, headingDegrees: 30), 60);
    });

    test('wraps across north', () {
      expect(
        arrowRotationDegrees(bearingDegrees: 10, headingDegrees: 350),
        closeTo(20, 1e-9),
      );
      expect(
        arrowRotationDegrees(bearingDegrees: 350, headingDegrees: 10),
        closeTo(340, 1e-9),
      );
    });

    test('is 0 when facing the target', () {
      expect(arrowRotationDegrees(bearingDegrees: 123, headingDegrees: 123), 0);
    });
  });

  group('shortestArcDegrees', () {
    test('crossing 0 turns forward by 2°, not back by 358°', () {
      expect(shortestArcDegrees(359, 1), closeTo(2, 1e-9));
    });

    test('crossing 0 backwards turns by -2°', () {
      expect(shortestArcDegrees(1, 359), closeTo(-2, 1e-9));
    });

    test('plain turns keep their sign', () {
      expect(shortestArcDegrees(10, 100), 90);
      expect(shortestArcDegrees(100, 10), -90);
    });

    test('a half turn resolves to +180', () {
      expect(shortestArcDegrees(0, 180), 180);
    });

    test('accepts unwrapped input', () {
      expect(shortestArcDegrees(718, 2), closeTo(4, 1e-9));
    });
  });

  group('continuousRotationDegrees', () {
    test('keeps growing past 360 instead of jumping back', () {
      expect(continuousRotationDegrees(358, 2), closeTo(362, 1e-9));
    });

    test('keeps shrinking below 0', () {
      expect(continuousRotationDegrees(2, 358), closeTo(-2, 1e-9));
    });

    test('a sweep around the dial never moves more than the step', () {
      var angle = 0.0;
      for (var target = 0.0; target < 720; target += 10) {
        final next = continuousRotationDegrees(angle, target % 360);
        expect((next - angle).abs(), lessThanOrEqualTo(10 + 1e-9));
        angle = next;
      }
      expect(angle, closeTo(710, 1e-6));
    });
  });

  group('normalizeDegrees', () {
    test('wraps into 0..360', () {
      expect(normalizeDegrees(-90), 270);
      expect(normalizeDegrees(450), 90);
      expect(normalizeDegrees(360), 0);
      expect(normalizeDegrees(-1e-14), 0);
    });
  });

  group('cardinalDirection', () {
    test('each direction sits at the middle of its sector', () {
      expect(cardinalDirection(0), CardinalDirection.north);
      expect(cardinalDirection(45), CardinalDirection.northEast);
      expect(cardinalDirection(90), CardinalDirection.east);
      expect(cardinalDirection(135), CardinalDirection.southEast);
      expect(cardinalDirection(180), CardinalDirection.south);
      expect(cardinalDirection(225), CardinalDirection.southWest);
      expect(cardinalDirection(270), CardinalDirection.west);
      expect(cardinalDirection(315), CardinalDirection.northWest);
    });

    test('a sector spans 45 degrees, ends included on the lower side', () {
      expect(cardinalDirection(22.4), CardinalDirection.north);
      expect(cardinalDirection(22.5), CardinalDirection.northEast);
      expect(cardinalDirection(67.4), CardinalDirection.northEast);
      expect(cardinalDirection(67.5), CardinalDirection.east);
    });

    test('north wraps around zero', () {
      expect(cardinalDirection(337.5), CardinalDirection.north);
      expect(cardinalDirection(359.9), CardinalDirection.north);
      expect(cardinalDirection(360), CardinalDirection.north);
    });

    test('angles outside 0..360 are wrapped first', () {
      expect(cardinalDirection(-90), CardinalDirection.west);
      expect(cardinalDirection(450), CardinalDirection.east);
    });

    test('the mockup bearing reads north-west', () {
      expect(cardinalDirection(320), CardinalDirection.northWest);
    });
  });
}
