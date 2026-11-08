part of 'point_import_bloc.dart';

sealed class PointImportEvent {
  const PointImportEvent();
}

/// Reads the saved points and the current position.
final class PointImportStarted extends PointImportEvent {
  const PointImportStarted();
}

final class PointImportTextEdited extends PointImportEvent {
  const PointImportTextEdited(this.text);

  final String text;
}

/// The user tried to save text that holds no coordinates.
final class PointImportRejected extends PointImportEvent {
  const PointImportRejected();
}
