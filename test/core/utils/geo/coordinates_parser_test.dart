import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/utils/geo/coordinates_parser.dart';

void main() {
  const lat = 56.50353;
  const lon = 85.03131;

  void reads(String text, double latitude, double longitude) {
    final parsed = parseCoordinates(text);
    expect(parsed, isNotNull, reason: text);
    expect(parsed!.point.latitude, closeTo(latitude, 1e-4), reason: text);
    expect(parsed.point.longitude, closeTo(longitude, 1e-4), reason: text);
  }

  group('plain numbers', () {
    for (final text in [
      '56.50353, 85.03131',
      '56.50353,85.03131',
      '56.50353 85.03131',
      '56.50353; 85.03131',
      '  56.50353   85.03131  ',
      '56,50353 85,03131',
      '56,50353; 85,03131',
    ]) {
      test(text, () => reads(text, lat, lon));
    }

    test(
      'negative values',
      () => reads('-33.86882, -151.20930', -33.86882, -151.2093),
    );

    test('inside a sentence', () {
      reads('Встречаемся тут: 56.50353, 85.03131, у моста', lat, lon);
    });

    test('rough numbers are read but not precise', () {
      expect(parseCoordinates('56.5, 85')!.isPrecise, isFalse);
      expect(parseCoordinates('56, 85')!.isPrecise, isFalse);
      expect(parseCoordinates('56.50, 85.03')!.isPrecise, isFalse);
      expect(parseCoordinates('56.503, 85.031')!.isPrecise, isTrue);
    });
  });

  group('with hemispheres', () {
    for (final text in [
      'N56.50353 E85.03131',
      'N 56.50353, E 85.03131',
      '56.50353N 85.03131E',
      '56.50353 С 85.03131 В',
      '56,50353 с.ш. 85,03131 в.д.',
      'E85.03131 N56.50353',
    ]) {
      test(text, () => reads(text, lat, lon));
    }

    test('south and west are negative', () {
      reads('S33.86882 W151.20930', -33.86882, -151.2093);
      reads('33.86882 Ю 151.20930 З', -33.86882, -151.2093);
    });

    test('two latitudes are refused', () {
      expect(parseCoordinates('N56.5 N85.0'), isNull);
    });
  });

  group('degrees', () {
    test('with minutes', () {
      reads("56°30.212' 85°01.879'", 56.50353, 85.03132);
    });

    test('with minutes and seconds', () {
      reads('''56°30'12.7"N 85°01'52.7"E''', 56.50353, 85.03131);
    });

    test('hemisphere first', () {
      reads('''N56°30'12.7" E85°01'52.7"''', 56.50353, 85.03131);
    });

    test('typographic marks and Russian letters', () {
      reads('56°30′12.7″ С 85°01′52.7″ В', 56.50353, 85.03131);
    });

    test('south is negative', () {
      reads('''33°52'07.8"S 151°12'33.5"W''', -33.8688, -151.2093);
    });

    test('degrees alone are not precise', () {
      expect(parseCoordinates('56° 85°')!.isPrecise, isFalse);
    });

    test('whole minutes are not precise, seconds are', () {
      expect(parseCoordinates("56°30' 85°01'")!.isPrecise, isFalse);
      expect(parseCoordinates('''56°30'12" 85°01'52"''')!.isPrecise, isTrue);
    });

    test('impossible minutes are refused', () {
      expect(parseCoordinates("56°75.0' 85°01.0'"), isNull);
    });
  });

  group('links', () {
    test('geo', () => reads('geo:56.50353,85.03131', lat, lon));

    test('geo with a query', () {
      reads('geo:0,0?q=56.50353,85.03131(Машина)', lat, lon);
    });

    test('Google, view point', () {
      reads('https://www.google.com/maps/@56.50353,85.03131,15z', lat, lon);
    });

    test('Google, marker before view', () {
      reads(
        'https://www.google.com/maps/place/X/@10.5,20.5,15z/data=!3d56.50353!4d85.03131',
        lat,
        lon,
      );
    });

    test('Google, query', () {
      reads('https://maps.google.com/?q=56.50353,85.03131', lat, lon);
    });

    test('Google, encoded comma', () {
      reads('https://www.google.com/maps?q=56.50353%2C85.03131', lat, lon);
    });

    test('Yandex is longitude first', () {
      reads('https://yandex.ru/maps/?ll=85.03131%2C56.50353&z=15', lat, lon);
    });

    test('Yandex marker before map center', () {
      reads(
        'https://yandex.ru/maps/?ll=20.5%2C10.5&pt=85.03131,56.50353&z=15',
        lat,
        lon,
      );
    });

    test('a short link has nothing to read', () {
      expect(parseCoordinates('https://maps.app.goo.gl/AbCd123'), isNull);
    });
  });

  group('refused', () {
    for (final text in [
      '',
      '   ',
      'где-то у реки',
      '56.50353',
      '91.0, 85.0',
      '56.0, 181.0',
      // One number with a decimal comma, or a pair?
      '56,85',
      '56,5 85',
    ]) {
      test('"$text"', () => expect(parseCoordinates(text), isNull));
    }
  });
}
