/// The persistent notice of background navigation (mvp-scope.md §2.8):
/// localized by the view, shown by the platform.
final class NavigationNotice {
  const NavigationNotice({
    required this.title,
    required this.text,
    required this.stopLabel,
    required this.channelName,
  });

  final String title;
  final String text;
  final String stopLabel;

  /// How the system settings name this kind of notification.
  final String channelName;

  @override
  bool operator ==(Object other) =>
      other is NavigationNotice &&
      other.title == title &&
      other.text == text &&
      other.stopLabel == stopLabel &&
      other.channelName == channelName;

  @override
  int get hashCode => Object.hash(title, text, stopLabel, channelName);
}
