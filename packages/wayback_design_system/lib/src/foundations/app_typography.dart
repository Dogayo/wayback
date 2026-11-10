import 'package:flutter/material.dart';

abstract final class WbTypography {
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  /// The number of a hero distance, on top of its text style. Only digits
  /// are drawn from it: Barlow has no Cyrillic, so units stay native.
  static const TextStyle distanceNumber = TextStyle(
    fontFamily: 'Barlow',
    package: 'wayback_design_system',
    fontWeight: FontWeight.w600,
  );

  static TextTheme textTheme(Color color) => TextTheme(
    displayLarge: _style(
      88,
      96,
      FontWeight.w700,
      color,
      letterSpacing: -1.76,
      numeric: true,
    ),
    displaySmall: _style(
      34,
      40,
      FontWeight.w700,
      color,
      letterSpacing: -0.68,
      numeric: true,
    ),
    headlineSmall: _style(24, 30, FontWeight.w700, color),
    titleLarge: _style(20, 26, FontWeight.w600, color),
    titleMedium: _style(16, 22, FontWeight.w600, color),
    bodyLarge: _style(16, 24, FontWeight.w400, color),
    bodyMedium: _style(14, 20, FontWeight.w400, color),
    labelLarge: _style(15, 20, FontWeight.w600, color),
    labelMedium: _style(13, 18, FontWeight.w600, color),
    bodySmall: _style(12, 16, FontWeight.w500, color, letterSpacing: .24),
  );

  static TextStyle _style(
    double size,
    double lineHeight,
    FontWeight weight,
    Color color, {
    double? letterSpacing,
    bool numeric = false,
  }) => TextStyle(
    fontSize: size,
    height: lineHeight / size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    fontFeatures: numeric ? tabularFigures : null,
  );
}
