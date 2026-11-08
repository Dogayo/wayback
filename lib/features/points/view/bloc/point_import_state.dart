part of 'point_import_bloc.dart';

typedef NearbyPoint = ({String name, double meters});

final class PointImportState {
  const PointImportState({
    required this.text,
    this.draft,
    this.here,
    this.nearby,
    this.errorVisible = false,
  });

  final String text;

  /// What [text] says; `null` when it holds no coordinates.
  final PointDraft? draft;

  /// Where the user is, once known.
  final GeoPoint? here;

  /// A saved point at practically the same place.
  final NearbyPoint? nearby;

  final bool errorVisible;

  double? get distanceFromHere => switch ((here, draft)) {
    (final here?, final draft?) => distanceMeters(here, draft.position),
    _ => null,
  };

  PointImportState copyWith({required bool errorVisible}) => PointImportState(
    text: text,
    draft: draft,
    here: here,
    nearby: nearby,
    errorVisible: errorVisible,
  );
}
