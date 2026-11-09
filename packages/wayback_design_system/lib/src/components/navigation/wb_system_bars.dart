import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Transparent system bars for a screen that reaches the edges, with icons
/// readable on [background]. The innermost one on screen wins.
class WbSystemBars extends StatelessWidget {
  const WbSystemBars({
    required this.background,
    required this.child,
    super.key,
  });

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    final icons = brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: icons,
        statusBarBrightness: brightness,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: icons,
        systemNavigationBarContrastEnforced: false,
      ),
      child: child,
    );
  }
}
