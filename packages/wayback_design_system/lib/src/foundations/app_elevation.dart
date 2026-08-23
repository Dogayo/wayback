import 'package:flutter/widgets.dart';

import 'package:wayback_design_system/src/foundations/app_colors.dart';

abstract final class WbElevation {
  static List<BoxShadow> level1(Brightness brightness) => const [];

  static List<BoxShadow> level2(Brightness brightness) =>
      brightness == Brightness.dark
      ? const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x1A14181D),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x1414181D),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ];

  static List<BoxShadow> level3(Brightness brightness) =>
      brightness == Brightness.dark
      ? const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x2414181D),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x1414181D),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ];

  static List<BoxShadow> level4(Brightness brightness) =>
      brightness == Brightness.dark
      ? const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x3314181D),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x1A14181D),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ];

  static Color scrim(Brightness brightness) => brightness == Brightness.dark
      ? WbColors.dark.scrim
      : WbColors.light.scrim;
}
