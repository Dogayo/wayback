import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';

part 'action_event.dart';
part 'action_state.dart';

/// One user action with parameters [P] and result [T]: save, rename,
/// delete, open settings.
///
/// A start while the action runs is ignored (`droppable`), so a double tap
/// cannot save twice.
abstract class ActionBloc<P, T> extends Bloc<ActionEvent<P>, ActionState<T>> {
  ActionBloc() : super(ActionIdle<T>()) {
    on<ActionStarted<P>>(_onStarted, transformer: droppable());
    on<ActionReset<P>>((_, emit) => emit(ActionIdle<T>()));
  }

  /// Does the work; called once per start.
  Future<Result<T>> perform(P params);

  void run(P params) => add(ActionStarted<P>(params));

  /// Back to [ActionIdle], e.g. after a failure was shown.
  void reset() => add(ActionReset<P>());

  Future<void> _onStarted(
    ActionStarted<P> event,
    Emitter<ActionState<T>> emit,
  ) async {
    emit(ActionInProgress<T>());
    final Result<T> result;
    try {
      result = await perform(event.params);
    } on Object catch (error, stackTrace) {
      // Repositories never throw; this guards logic in perform() itself.
      emit(
        ActionFailure<T>(
          UnexpectedFailure(
            description: '$error',
            cause: error,
            stackTrace: stackTrace,
          ),
        ),
      );
      return;
    }
    emit(switch (result) {
      Success(:final value) => ActionSuccess<T>(value),
      Failed(:final failure) => ActionFailure<T>(failure),
    });
  }
}
