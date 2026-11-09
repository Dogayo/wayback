import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/geo/geo_math.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/points/domain/entities/point_draft.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

part 'point_import_event.dart';
part 'point_import_state.dart';

/// Reads coordinates typed, pasted or received, and tells how far they are
/// from here and from the points already saved.
final class PointImportBloc extends Bloc<PointImportEvent, PointImportState> {
  PointImportBloc(this._points, this._location, {String text = ''})
    : super(PointImportState(text: text, draft: parsePointText(text))) {
    on<PointImportStarted>(_onStarted);
    on<PointImportTextEdited>(
      (event, emit) => emit(_reading(event.text, here: state.here)),
    );
    on<PointImportRejected>(
      (_, emit) => emit(state.copyWith(errorVisible: true)),
    );
  }

  final PointsRepository _points;
  final LocationRepository _location;

  List<SavedPoint> _saved = const [];

  Future<void> _onStarted(
    PointImportStarted event,
    Emitter<PointImportState> emit,
  ) async {
    if (await _points.watchAll().first case Success(:final value)) {
      _saved = value;
      emit(_reading(state.text, here: state.here));
    }
    if (await _location.currentFix() case Success(:final value)) {
      emit(_reading(state.text, here: value.point));
    }
  }

  PointImportState _reading(String text, {required GeoPoint? here}) {
    final draft = parsePointText(text);
    return PointImportState(
      text: text,
      draft: draft,
      here: here,
      nearby: draft == null ? null : _nearest(draft.position),
    );
  }

  NearbyPoint? _nearest(GeoPoint position) {
    NearbyPoint? nearest;
    for (final point in _saved) {
      final meters = distanceMeters(position, point.position);
      if (meters <= _nearbyMeters &&
          meters < (nearest?.meters ?? _nearbyMeters + 1)) {
        nearest = (name: point.name, meters: meters);
      }
    }
    return nearest;
  }
}

/// Closer than this, a point is probably the same place as one already saved.
const _nearbyMeters = 10.0;
