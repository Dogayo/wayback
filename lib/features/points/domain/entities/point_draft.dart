import 'package:wayback/core/utils/geo/coordinates_parser.dart';
import 'package:wayback/core/utils/geo/geo_format.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/points/domain/entities/point_naming.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';

/// What can be told about a point from text, before the user accepts it.
final class PointDraft {
  const PointDraft({
    required this.position,
    required this.isPrecise,
    this.name,
    this.type,
  });

  final GeoPoint position;
  final bool isPrecise;
  final String? name;
  final PointType? type;
}

/// A link any Wayback can open. It carries only what the other person needs:
/// no id, date or activity of this phone's copy.
String pointShareLink(SavedPoint point) => Uri(
  scheme: 'wayback',
  host: 'app',
  path: 'import',
  queryParameters: {
    'v': _linkVersion,
    'lat': point.position.latitude.toStringAsFixed(_linkDecimals),
    'lon': point.position.longitude.toStringAsFixed(_linkDecimals),
    't': point.type.name,
    'n': point.name,
  },
).toString();

/// A message that reads well anywhere: the name and coordinates work for a
/// person and any map, the link for Wayback.
String pointShareText(SavedPoint point) =>
    '${point.name}\n'
    '${formatCoordinates(point.position)}\n'
    '${pointShareLink(point)}';

const _linkVersion = '1';

/// About 1 m on the ground.
const _linkDecimals = 5;

final _link = RegExp(r'wayback://app/import\?\S+', caseSensitive: false);

const _linkPreciseDecimals = 3;

/// What the import screen starts with, from the query of its route: text
/// shared to the app as it came, or a link. A link that holds no point is
/// dropped, since the address itself would mean nothing in the field.
String pointImportText(Map<String, String> query) {
  if (query['text'] case final text?) return text;
  if (!query.containsKey('lat')) return '';
  final link = Uri(
    scheme: 'wayback',
    host: 'app',
    path: 'import',
    queryParameters: query,
  ).toString();
  return parsePointText(link) == null ? '' : link;
}

/// A point from a Wayback link, a whole shared message or bare coordinates.
/// Everything here comes from outside the app, so nothing in it is trusted:
/// out-of-range coordinates are refused, a long name is cut, an unknown type
/// is dropped.
PointDraft? parsePointText(String text) {
  if (_link.firstMatch(text) case final match?) {
    if (_fromLink(match[0]!) case final draft?) return draft;
  }
  final parsed = parseCoordinates(text);
  if (parsed == null) return null;
  return PointDraft(
    position: parsed.point,
    isPrecise: parsed.isPrecise,
    name: _firstLineName(text),
  );
}

PointDraft? _fromLink(String link) {
  final query = Uri.tryParse(link)?.queryParameters;
  if (query == null) return null;
  final latitude = double.tryParse(query['lat'] ?? '');
  final longitude = double.tryParse(query['lon'] ?? '');
  if (latitude == null || longitude == null) return null;
  if (latitude.abs() > 90 || longitude.abs() > 180) return null;
  return PointDraft(
    position: GeoPoint(latitude: latitude, longitude: longitude),
    isPrecise:
        _decimals(query['lat']!) >= _linkPreciseDecimals &&
        _decimals(query['lon']!) >= _linkPreciseDecimals,
    name: _name(query['n']),
    type: PointType.values.asNameMap()[query['t']],
  );
}

/// A message like `Машина` over its coordinates: the first line is the name.
String? _firstLineName(String text) {
  final lines = [
    for (final line in text.split('\n'))
      if (line.trim().isNotEmpty) line.trim(),
  ];
  if (lines.length < 2) return null;
  final first = lines.first;
  return first.contains('://') || parseCoordinates(first) != null
      ? null
      : _name(first);
}

String? _name(String? raw) {
  final name = raw?.trim();
  if (name == null || name.isEmpty) return null;
  return String.fromCharCodes(name.runes.take(pointNameMaxLength));
}

int _decimals(String number) {
  final separator = number.indexOf('.');
  return separator == -1 ? 0 : number.length - separator - 1;
}
