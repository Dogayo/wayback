import 'package:wayback/core/utils/geo/geo_point.dart';

/// A position found in free text.
final class ParsedCoordinates {
  const ParsedCoordinates(this.point, {required this.isPrecise});

  final GeoPoint point;

  /// False when the text gives too few digits to trust within tens of
  /// meters: two decimals of a degree are already about a kilometer.
  final bool isPrecise;
}

const _minPreciseDecimals = 3;
const _minPreciseMinuteDecimals = 2;
const _minutesPerDegree = 60;
const _secondsPerDegree = 3600;

const _letter = '[NSEWСЮВЗ]';
const _number = r'\d{1,3}(?:[.,]\d+)?';
const _notLetter = '[A-ZА-ЯЁ]';
const _degreesPart =
    '($_number)'
    r'\s*°\s*'
    r"(?:(\d{1,2}(?:[.,]\d+)?)\s*'\s*(?:(\d{1,2}(?:[.,]\d+)?)\s*"
    r'"\s*)?)?';

final _degreesAfterLetter = RegExp('($_letter)\\s*(-?)$_degreesPart');
final _degreesBeforeLetter = RegExp('(-?)$_degreesPart($_letter)?');
final _numberAfterLetter = RegExp(
  '(?<!$_notLetter)($_letter)\\s*($_number)(?!\\d)',
);
final _numberBeforeLetter = RegExp(
  '(?<![\\d.,])($_number)\\s*($_letter)(?!$_notLetter)',
);

final _dotPair = RegExp(
  r'(?<![\d.,-])(-?\d{1,3}\.\d+)\s*[,;/\s]\s*(-?\d{1,3}\.\d+)(?![\d.])',
);
final _commaPair = RegExp(
  r'(?<![\d.,-])(-?\d{1,3},\d+)\s*[;/\s]\s*(-?\d{1,3},\d+)(?![\d,])',
);
final _wholeInput = RegExp(
  r'^\s*(-?\d{1,3}(?:\.\d+)?)\s*[,;/\s]\s*(-?\d{1,3}(?:\.\d+)?)\s*$',
);

/// `56,85` could be one number with a decimal comma as well as a pair.
final _bareComma = RegExp(r'^\s*-?\d+,-?\d+\s*$');

final _geoUri = RegExp(
  r'geo:\s*(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)',
  caseSensitive: false,
);

const _pair = r'(-?\d{1,3}\.\d+),(-?\d{1,3}\.\d+)';

/// Latitude first, the most exact place first.
final _latitudeFirstLinks = [
  RegExp(r'!3d(-?\d{1,3}\.\d+)!4d(-?\d{1,3}\.\d+)'),
  RegExp('[?&](?:q|query|destination|daddr)=$_pair'),
  RegExp('[?&](?:ll|center)=$_pair'),
  RegExp('@$_pair'),
];

/// Yandex writes longitude first, the marker before the map center.
final _longitudeFirstLinks = [
  RegExp('[?&]pt=$_pair'),
  RegExp('[?&]whatshere\\[point\\]=$_pair'),
  RegExp('[?&]ll=$_pair'),
];

/// Finds a position in [text]: numbers in several notations, degrees with
/// minutes and seconds, `geo:`, or a full Google or Yandex Maps link.
///
/// Returns `null` when there is none, or when it could be read more than
/// one way: a wrong guess would lead somewhere else.
ParsedCoordinates? parseCoordinates(String text) {
  final clean = _normalized(text);
  final upper = _withHemispheres(clean.toUpperCase());
  return _fromMapLink(clean) ??
      _fromGeoUri(clean) ??
      _fromDegrees(upper) ??
      _fromLetters(upper) ??
      _fromPlainNumbers(clean);
}

String _normalized(String text) => text
    .replaceAll(RegExp('[′’‘`]'), "'")
    .replaceAll(RegExp('[″”“]'), '"')
    .replaceAll("''", '"')
    .replaceAll('º', '°')
    .replaceAll(RegExp('%2C', caseSensitive: false), ',')
    .replaceAll(RegExp('%5B', caseSensitive: false), '[')
    .replaceAll(RegExp('%5D', caseSensitive: false), ']');

/// `с.ш.` and the like, as single letters.
String _withHemispheres(String upper) => upper
    .replaceAll(RegExp(r'С\.?\s*Ш\.?'), 'С')
    .replaceAll(RegExp(r'Ю\.?\s*Ш\.?'), 'Ю')
    .replaceAll(RegExp(r'В\.?\s*Д\.?'), 'В')
    .replaceAll(RegExp(r'З\.?\s*Д\.?'), 'З');

ParsedCoordinates? _fromMapLink(String text) {
  final longitudeFirst = RegExp(
    r'yandex\.|ya\.ru',
    caseSensitive: false,
  ).hasMatch(text);
  for (final link
      in longitudeFirst ? _longitudeFirstLinks : _latitudeFirstLinks) {
    if (link.firstMatch(text) case final match?) {
      final (first, second) = (match[1]!, match[2]!);
      return longitudeFirst ? _decimal(second, first) : _decimal(first, second);
    }
  }
  return null;
}

ParsedCoordinates? _fromGeoUri(String text) {
  final match = _geoUri.firstMatch(text);
  return match == null ? null : _decimal(match[1]!, match[2]!);
}

ParsedCoordinates? _fromDegrees(String upper) {
  final after = _degreesAfterLetter.allMatches(upper).toList();
  if (after.length == 2) {
    return _fromAxes([
      for (final m in after)
        (
          letter: m[1],
          sign: m[2]!,
          degrees: m[3]!,
          minutes: m[4],
          seconds: m[5],
        ),
    ]);
  }
  final before = _degreesBeforeLetter.allMatches(upper).toList();
  if (before.length != 2) return null;
  return _fromAxes([
    for (final m in before)
      (letter: m[5], sign: m[1]!, degrees: m[2]!, minutes: m[3], seconds: m[4]),
  ]);
}

typedef _Axis = ({
  String? letter,
  String sign,
  String degrees,
  String? minutes,
  String? seconds,
});

ParsedCoordinates? _fromAxes(List<_Axis> axes) {
  final values = <double>[];
  var precise = true;
  for (final axis in axes) {
    final minutes = _value(axis.minutes ?? '0');
    final seconds = _value(axis.seconds ?? '0');
    if (minutes >= _minutesPerDegree || seconds >= _minutesPerDegree) {
      return null;
    }
    final value =
        _value(axis.degrees) +
        minutes / _minutesPerDegree +
        seconds / _secondsPerDegree;
    values.add(axis.sign == '-' ? -value : value);
    precise =
        precise &&
        (axis.seconds != null ||
            _decimals(axis.minutes ?? '') >= _minPreciseMinuteDecimals ||
            _decimals(axis.degrees) >= _minPreciseDecimals);
  }
  return _ordered(values, [axes[0].letter, axes[1].letter], isPrecise: precise);
}

ParsedCoordinates? _fromLetters(String upper) {
  for (final (pattern, letterGroup, numberGroup) in [
    (_numberAfterLetter, 1, 2),
    (_numberBeforeLetter, 2, 1),
  ]) {
    final found = pattern.allMatches(upper).toList();
    if (found.length != 2) continue;
    final parsed = _ordered(
      [for (final m in found) _value(m[numberGroup]!)],
      [for (final m in found) m[letterGroup]],
      isPrecise: found.every(
        (m) => _decimals(m[numberGroup]!) >= _minPreciseDecimals,
      ),
    );
    if (parsed != null) return parsed;
  }
  return null;
}

/// Puts [values] in latitude, longitude order by their hemisphere [letters],
/// and signs them. Without letters the order is latitude, longitude.
ParsedCoordinates? _ordered(
  List<double> values,
  List<String?> letters, {
  required bool isPrecise,
}) {
  if (letters.every((letter) => letter == null)) {
    return _checked(values[0], values[1], isPrecise: isPrecise);
  }
  double? latitude;
  double? longitude;
  for (var i = 0; i < values.length; i++) {
    switch (letters[i]) {
      case 'N' || 'С':
        latitude = values[i];
      case 'S' || 'Ю':
        latitude = -values[i];
      case 'E' || 'В':
        longitude = values[i];
      case 'W' || 'З':
        longitude = -values[i];
      default:
        return null;
    }
  }
  if (latitude == null || longitude == null) return null;
  return _checked(latitude, longitude, isPrecise: isPrecise);
}

ParsedCoordinates? _fromPlainNumbers(String text) {
  for (final pair in [_dotPair, _commaPair]) {
    for (final match in pair.allMatches(text)) {
      if (_decimal(match[1]!, match[2]!) case final parsed?) return parsed;
    }
  }
  if (_bareComma.hasMatch(text)) return null;
  final whole = _wholeInput.firstMatch(text);
  return whole == null ? null : _decimal(whole[1]!, whole[2]!);
}

ParsedCoordinates? _decimal(String latitude, String longitude) => _checked(
  _value(latitude),
  _value(longitude),
  isPrecise:
      _decimals(latitude) >= _minPreciseDecimals &&
      _decimals(longitude) >= _minPreciseDecimals,
);

ParsedCoordinates? _checked(
  double latitude,
  double longitude, {
  required bool isPrecise,
}) => latitude.abs() > 90 || longitude.abs() > 180
    ? null
    : ParsedCoordinates(
        GeoPoint(latitude: latitude, longitude: longitude),
        isPrecise: isPrecise,
      );

double _value(String number) => double.parse(number.replaceAll(',', '.'));

int _decimals(String number) {
  final separator = number.indexOf(RegExp('[.,]'));
  return separator == -1 ? 0 : number.length - separator - 1;
}
