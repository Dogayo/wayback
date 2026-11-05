import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/points/domain/entities/point_naming.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';

part 'point_form_event.dart';
part 'point_form_state.dart';

/// Name and type of a new point (SCREENS.md §4.2). Until the user types a
/// name, the name follows the chosen type, numbered when taken.
final class PointFormBloc extends Bloc<PointFormEvent, PointFormState> {
  PointFormBloc(this._points, {required this.labelOf, required this.numbered})
    : super(
        PointFormState(
          name: labelOf(PointType.generic),
          defaultName: labelOf(PointType.generic),
          type: PointType.generic,
        ),
      ) {
    on<PointFormStarted>(_onStarted);
    on<PointFormTypeSelected>(
      (event, emit) => emit(_withType(state, event.type)),
    );
    on<PointFormNameEdited>(
      (event, emit) => emit(state.copyWith(name: event.name, nameEdited: true)),
    );
  }

  final PointsRepository _points;

  /// Localized type label, also the default name.
  final String Function(PointType type) labelOf;

  /// Localized "label number" form for a taken default name.
  final String Function(String label, int number) numbered;

  List<String> _existingNames = const [];

  Future<void> _onStarted(
    PointFormStarted event,
    Emitter<PointFormState> emit,
  ) async {
    if (await _points.watchAll().first case Success(:final value)) {
      _existingNames = [for (final point in value) point.name];
      emit(_withType(state, state.type));
    }
  }

  PointFormState _withType(PointFormState state, PointType type) {
    final defaultName = defaultPointName(
      label: labelOf(type),
      existingNames: _existingNames,
      numbered: numbered,
    );
    return state.copyWith(
      type: type,
      defaultName: defaultName,
      name: state.nameEdited ? state.name : defaultName,
    );
  }
}
