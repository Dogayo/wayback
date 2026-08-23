import 'package:flutter/animation.dart';

abstract final class WbMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration compassSmoothing = Duration(milliseconds: 120);
  static const Duration shimmer = Duration(milliseconds: 1400);

  static const Curve standard = Cubic(0.2, 0, 0, 1);
  static const Curve ios = Cubic(0.25, 0.1, 0.25, 1);
  static const Curve easeOut = Cubic(0, 0, 0.2, 1);
}
