/// The persistent notice of background navigation (mvp-scope.md §2.8):
/// localized by the view, shown by the platform.
final class NavigationNotice {
  const NavigationNotice({
    required this.title,
    required this.text,
    required this.stopLabel,
    required this.channelName,
    this.direction,
    this.bearingDegrees,
    this.arrived = false,
  });

  final String title;
  final String text;
  final String stopLabel;

  /// How the system settings name this kind of notification.
  final String channelName;

  /// Which way the point lies, against north, e.g. `СЗ · 320°`.
  /// Only the iOS Live Activity shows it; the Android notice ignores it.
  final String? direction;

  /// The same bearing as a number, for the arrow the iOS activity draws.
  /// `null` when there is no direction to show.
  final double? bearingDegrees;

  /// Whether the user is inside the arrival radius. The platform drops
  /// the distance and the direction when they are.
  final bool arrived;

  @override
  bool operator ==(Object other) =>
      other is NavigationNotice &&
      other.title == title &&
      other.text == text &&
      other.stopLabel == stopLabel &&
      other.channelName == channelName &&
      other.direction == direction &&
      other.bearingDegrees == bearingDegrees &&
      other.arrived == arrived;

  @override
  int get hashCode => Object.hash(
    title,
    text,
    stopLabel,
    channelName,
    direction,
    bearingDegrees,
    arrived,
  );
}
