part of 'action_bloc.dart';

sealed class ActionEvent<P> {
  const ActionEvent();
}

final class ActionStarted<P> extends ActionEvent<P> {
  const ActionStarted(this.params);

  final P params;
}

final class ActionReset<P> extends ActionEvent<P> {
  const ActionReset();
}
