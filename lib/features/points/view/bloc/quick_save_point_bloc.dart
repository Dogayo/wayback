import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/points/domain/entities/point_naming.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Saves the current place in one tap (mvp-scope.md, one action to save).
///
/// The result is `null` when that cannot be done honestly, with no fix or a
/// weak one: the form takes over and explains, so a bad point is never saved
/// without the user seeing it.
final class QuickSavePointBloc extends ActionBloc<void, SavedPoint?> {
  QuickSavePointBloc(
    this._points,
    this._location, {
    required this.label,
    required this.numbered,
  });

  final PointsRepository _points;
  final LocationRepository _location;

  /// Localized label of the neutral type, also the default name.
  final String label;

  /// Localized "label number" form for a taken default name.
  final String Function(String label, int number) numbered;

  @override
  Future<Result<SavedPoint?>> perform(void params) async {
    final fix = switch (await _location.currentFix()) {
      Success(:final value) when !value.isWeakSignal => value,
      _ => null,
    };
    if (fix == null) return const Result.success(null);
    final existing = switch (await _points.watchAll().first) {
      Success(:final value) => [for (final point in value) point.name],
      Failed() => const <String>[],
    };
    return _points.create(
      name: defaultPointName(
        label: label,
        existingNames: existing,
        numbered: numbered,
      ),
      type: PointType.generic,
      position: fix.point,
      altitudeMeters: fix.altitudeMeters,
    );
  }
}
