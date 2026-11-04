import 'package:flutter/material.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Themes of the app. All visual tokens come from the design system.
abstract final class AppTheme {
  static ThemeData get light => WbTheme.light;
  static ThemeData get dark => WbTheme.dark;
}
