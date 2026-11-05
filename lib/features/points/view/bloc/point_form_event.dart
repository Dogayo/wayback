part of 'point_form_bloc.dart';

sealed class PointFormEvent {
  const PointFormEvent();
}

/// Reads the names in use, so the default name can skip them.
final class PointFormStarted extends PointFormEvent {
  const PointFormStarted();
}

final class PointFormTypeSelected extends PointFormEvent {
  const PointFormTypeSelected(this.type);

  final PointType type;
}

final class PointFormNameEdited extends PointFormEvent {
  const PointFormNameEdited(this.name);

  final String name;
}
