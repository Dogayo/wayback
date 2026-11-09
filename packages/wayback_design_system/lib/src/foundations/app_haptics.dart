import 'package:flutter/widgets.dart';

/// How strongly the phone answers (DESIGN_SYSTEM.md, «Отклик»).
enum WbHaptic {
  /// Something was switched.
  tick,

  /// A special gesture worked, something opened.
  press,

  /// An important action is done.
  success,

  /// A refusal or an error.
  warning,
}

typedef WbHapticPlayer = void Function(WbHaptic haptic);

/// Makes the phone answer. The design system only says when: the app says
/// how, through a [WbHapticsScope], so no vibration package is needed here.
abstract final class WbHaptics {
  /// Does nothing without a [WbHapticsScope] above [context].
  static void play(BuildContext context, WbHaptic haptic) =>
      playerOf(context)?.call(haptic);

  /// For an answer given after [context] may be gone.
  static WbHapticPlayer? playerOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<WbHapticsScope>()?.player;
}

class WbHapticsScope extends InheritedWidget {
  const WbHapticsScope({required this.player, required super.child, super.key});

  final WbHapticPlayer player;

  @override
  bool updateShouldNotify(WbHapticsScope oldWidget) =>
      player != oldWidget.player;
}
