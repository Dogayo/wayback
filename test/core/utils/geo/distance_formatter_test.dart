import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/utils/geo/distance_formatter.dart';

FormattedDistance _m(String value) =>
    FormattedDistance(value: value, unit: DistanceUnit.meters);
FormattedDistance _km(String value) =>
    FormattedDistance(value: value, unit: DistanceUnit.kilometers);

void main() {
  group('meters below 1000 m', () {
    test('rounds to whole meters', () {
      expect(formatDistance(0, locale: 'en'), _m('0'));
      expect(formatDistance(12.4, locale: 'en'), _m('12'));
      expect(formatDistance(12.5, locale: 'en'), _m('13'));
      expect(formatDistance(999.4, locale: 'en'), _m('999'));
    });
  });

  group('kilometers from 1000 m', () {
    test('uses one decimal', () {
      expect(formatDistance(1000, locale: 'en'), _km('1.0'));
      expect(formatDistance(1234, locale: 'en'), _km('1.2'));
      expect(formatDistance(1250, locale: 'en'), _km('1.3'));
      expect(formatDistance(12345, locale: 'en'), _km('12.3'));
    });

    test('999.6 m switches to kilometers instead of showing 1000 m', () {
      expect(formatDistance(999.6, locale: 'en'), _km('1.0'));
    });

    test('groups thousands of kilometers', () {
      expect(formatDistance(1234500, locale: 'en'), _km('1,234.5'));
    });
  });

  group('locale', () {
    test('ru uses a decimal comma', () {
      expect(formatDistance(1234, locale: 'ru'), _km('1,2'));
    });

    test('ru groups with a non-breaking space', () {
      expect(formatDistance(1234500, locale: 'ru'), _km('1 234,5'));
    });

    test('meters are unaffected by locale', () {
      expect(formatDistance(850, locale: 'ru'), _m('850'));
    });
  });

  group('imperial', () {
    FormattedDistance ft(String v) =>
        FormattedDistance(value: v, unit: DistanceUnit.feet);
    FormattedDistance mi(String v) =>
        FormattedDistance(value: v, unit: DistanceUnit.miles);
    FormattedDistance imperial(double meters) =>
        formatDistance(meters, locale: 'en', system: UnitSystem.imperial);

    test('whole feet below 0.1 mile, miles with one decimal beyond', () {
      expect(imperial(30.48), ft('100'));
      expect(imperial(160), ft('525'));
      expect(imperial(161), mi('0.1'));
      expect(imperial(2253), mi('1.4'));
    });

    test('rounding happens before the unit is chosen', () {
      // 527.6 ft rounds to 528 ft = 0.1 mi.
      expect(imperial(527.6 * metersPerFoot), mi('0.1'));
    });

    test('accuracy stays in whole feet', () {
      expect(
        formatAccuracy(8, locale: 'en', system: UnitSystem.imperial),
        ft('26'),
      );
      expect(formatAccuracy(8, locale: 'en'), _m('8'));
    });
  });
}
