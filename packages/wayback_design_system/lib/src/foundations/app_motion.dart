import 'package:flutter/widgets.dart';

/// Motion tokens (DESIGN_SYSTEM.md, «Движение»).
///
/// Enter with [easeOut], leave with [accelerate] about a quarter faster,
/// move within a screen with [standard].
abstract final class WbMotion {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration slowExit = Duration(milliseconds: 250);
  static const Duration compassSmoothing = Duration(milliseconds: 120);
  static const Duration shimmer = Duration(milliseconds: 1400);
  static const Duration undoWindow = Duration(seconds: 5);

  static const Curve standard = Cubic(0.2, 0, 0, 1);
  static const Curve ios = Cubic(0.25, 0.1, 0.25, 1);
  static const Curve easeOut = Cubic(0, 0, 0.2, 1);
  static const Curve accelerate = Cubic(0.3, 0, 0.8, 0.15);

  /// [duration], or zero when the system asks to remove animations.
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false
      ? Duration.zero
      : duration;
}
