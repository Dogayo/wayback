/// Longest name a point can be given; long enough for a real place, short
/// enough for a list row and a dialog title.
const pointNameMaxLength = 40;

/// Default name for a new point: the type label, numbered when taken —
/// "Машина", "Машина 2", "Машина 3" (docs/copy.md §7).
///
/// [numbered] builds the numbered form from the localized pattern.
String defaultPointName({
  required String label,
  required Iterable<String> existingNames,
  required String Function(String label, int number) numbered,
}) {
  final taken = existingNames.toSet();
  if (!taken.contains(label)) return label;
  for (var number = 2; ; number++) {
    final candidate = numbered(label, number);
    if (!taken.contains(candidate)) return candidate;
  }
}
