import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_haptics.dart';
import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

/// App bar action that switches the theme (05 · Motion, «WbThemeToggle»).
///
/// The icon shows the theme that is on now: the sun in the light one, the
/// moon in the dark one. On a change the icons swap through half a turn and
/// a cross-fade; with animations off they simply swap.
class WbThemeToggle extends StatelessWidget {
  const WbThemeToggle({
    required this.dark,
    required this.label,
    this.onPressed,
    super.key,
  });

  /// The theme that is on now.
  final bool dark;

  /// What the button does, for the tooltip and a screen reader.
  final String label;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final onPressed = this.onPressed;
    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        onPressed: onPressed == null
            ? null
            : () {
                WbHaptics.play(context, WbHaptic.tick);
                onPressed();
              },
        tooltip: label,
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        style: IconButton.styleFrom(
          foregroundColor: context.wbColors.contentPrimary,
        ),
        icon: AnimatedSwitcher(
          duration: WbMotion.of(context, WbMotion.base),
          switchInCurve: WbMotion.standard,
          switchOutCurve: WbMotion.standard,
          transitionBuilder: _swap,
          child: Icon(
            dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            key: ValueKey(dark),
            size: WbIconSize.lg,
          ),
        ),
      ),
    );
  }

  /// Half a turn, a scale from 0.8 and a fade: the icon leaves the way the
  /// next one arrives.
  static Widget _swap(Widget child, Animation<double> animation) =>
      RotationTransition(
        turns: Tween<double>(begin: .5, end: 1).animate(animation),
        child: ScaleTransition(
          scale: Tween<double>(begin: .8, end: 1).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
      );
}
