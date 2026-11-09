import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/features/points/domain/entities/point_draft.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';

void main() {
  test('a link brings name and type', () {
    final draft = parsePointText(
      'wayback://app/import?v=1&lat=56.50353&lon=85.03131&t=car&n=%D0%9C%D0%B0%D1%88%D0%B8%D0%BD%D0%B0',
    )!;

    expect(draft.position.latitude, 56.50353);
    expect(draft.position.longitude, 85.03131);
    expect(draft.name, 'Машина');
    expect(draft.type, PointType.car);
    expect(draft.isPrecise, isTrue);
  });

  test('a whole shared message is read through its link', () {
    final draft = parsePointText(
      'Машина\n56.50353, 85.03131\nwayback://app/import?v=1&lat=56.50353&lon=85.03131&t=tent&n=x',
    )!;

    expect(draft.type, PointType.tent);
    expect(draft.name, 'x');
  });

  test('a message without a link: the first line is the name', () {
    final draft = parsePointText('Машина\n56.50353, 85.03131')!;

    expect(draft.name, 'Машина');
    expect(draft.type, isNull);
  });

  test('bare coordinates have no name', () {
    expect(parsePointText('56.50353, 85.03131')!.name, isNull);
  });

  test('a link on the first line is not a name', () {
    final draft = parsePointText(
      'https://maps.google.com/?q=56.50353,85.03131\nсмотри',
    )!;
    expect(draft.name, isNull);
  });

  group('a link is not trusted', () {
    test('out of range coordinates fall back to nothing', () {
      expect(parsePointText('wayback://app/import?lat=95&lon=85.0'), isNull);
      expect(parsePointText('wayback://app/import?lat=x&lon=85.0'), isNull);
    });

    test('a long name is cut', () {
      final draft = parsePointText(
        'wayback://app/import?lat=56.5&lon=85.0&n=${'x' * 60}',
      )!;
      expect(draft.name, hasLength(40));
    });

    test('an unknown type is dropped', () {
      final draft = parsePointText(
        'wayback://app/import?lat=56.5&lon=85.0&t=spaceship',
      )!;
      expect(draft.type, isNull);
    });

    test('an empty name is no name', () {
      final draft = parsePointText(
        'wayback://app/import?lat=56.5&lon=85.0&n=%20',
      )!;
      expect(draft.name, isNull);
    });
  });

  group('pointImportText', () {
    test('no query is an empty form', () {
      expect(pointImportText(const {}), '');
    });

    test('shared text comes as it is', () {
      expect(
        pointImportText(const {'text': 'смотри 1.5 2.5'}),
        'смотри 1.5 2.5',
      );
    });

    test('a link is rebuilt once and reads back', () {
      final text = pointImportText(const {
        'lat': '56.50353',
        'lon': '85.03131',
        'n': 'Машина',
        't': 'car',
      });

      expect(RegExp('wayback://').allMatches(text), hasLength(1));
      final draft = parsePointText(text)!;
      expect(draft.name, 'Машина');
      expect(draft.type, PointType.car);
    });

    test('a link with no point in it is dropped', () {
      expect(pointImportText(const {'lat': '95', 'lon': '20.1'}), '');
    });
  });
}
