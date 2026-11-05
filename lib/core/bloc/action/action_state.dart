part of 'action_bloc.dart';

/// State of an [ActionBloc]. The view handles it through [map],
/// [mapOrElse] or [mapOrNull], never with `is` checks.
sealed class ActionState<T> {
  const ActionState();

  bool get isInProgress => this is ActionInProgress<T>;

  R map<R>({
    required R Function(ActionIdle<T> state) idle,
    required R Function(ActionInProgress<T> state) inProgress,
    required R Function(ActionSuccess<T> state) success,
    required R Function(ActionFailure<T> state) failure,
  }) => switch (this) {
    final ActionIdle<T> s => idle(s),
    final ActionInProgress<T> s => inProgress(s),
    final ActionSuccess<T> s => success(s),
    final ActionFailure<T> s => failure(s),
  };

  R mapOrElse<R>({
    required R Function(ActionState<T> state) orElse,
    R Function(ActionIdle<T> state)? idle,
    R Function(ActionInProgress<T> state)? inProgress,
    R Function(ActionSuccess<T> state)? success,
    R Function(ActionFailure<T> state)? failure,
  }) => map(
    idle: idle ?? orElse,
    inProgress: inProgress ?? orElse,
    success: success ?? orElse,
    failure: failure ?? orElse,
  );

  R? mapOrNull<R>({
    R Function(ActionIdle<T> state)? idle,
    R Function(ActionInProgress<T> state)? inProgress,
    R Function(ActionSuccess<T> state)? success,
    R Function(ActionFailure<T> state)? failure,
  }) => mapOrElse<R?>(
    orElse: (_) => null,
    idle: idle,
    inProgress: inProgress,
    success: success,
    failure: failure,
  );
}

final class ActionIdle<T> extends ActionState<T> {
  const ActionIdle();

  @override
  bool operator ==(Object other) => other is ActionIdle<T>;

  @override
  int get hashCode => (ActionIdle<T>).hashCode;
}

final class ActionInProgress<T> extends ActionState<T> {
  const ActionInProgress();

  @override
  bool operator ==(Object other) => other is ActionInProgress<T>;

  @override
  int get hashCode => (ActionInProgress<T>).hashCode;
}

final class ActionSuccess<T> extends ActionState<T> {
  const ActionSuccess(this.result);

  final T result;

  @override
  bool operator ==(Object other) =>
      other is ActionSuccess<T> && other.result == result;

  @override
  int get hashCode => Object.hash(ActionSuccess<T>, result);
}

final class ActionFailure<T> extends ActionState<T> {
  const ActionFailure(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      other is ActionFailure<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(ActionFailure<T>, failure);
}
