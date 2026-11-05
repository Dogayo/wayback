part of 'point_form_bloc.dart';

/// The form has one shape, so there is nothing to map over.
final class PointFormState {
  const PointFormState({
    required this.name,
    required this.defaultName,
    required this.type,
    this.nameEdited = false,
  });

  /// What the name field shows.
  final String name;

  /// The type label, numbered when taken; used when the name is left empty.
  final String defaultName;
  final PointType type;

  /// Once the user typed, choosing a type no longer replaces the name.
  final bool nameEdited;

  /// The name to save.
  String get resolvedName => name.trim().isEmpty ? defaultName : name.trim();

  PointFormState copyWith({
    String? name,
    String? defaultName,
    PointType? type,
    bool? nameEdited,
  }) => PointFormState(
    name: name ?? this.name,
    defaultName: defaultName ?? this.defaultName,
    type: type ?? this.type,
    nameEdited: nameEdited ?? this.nameEdited,
  );

  @override
  bool operator ==(Object other) =>
      other is PointFormState &&
      other.name == name &&
      other.defaultName == defaultName &&
      other.type == type &&
      other.nameEdited == nameEdited;

  @override
  int get hashCode => Object.hash(name, defaultName, type, nameEdited);
}
