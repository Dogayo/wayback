import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_elevation.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbCard extends StatelessWidget {
  const WbCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.level = 2,
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final int level;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final shadows = switch (level) {
      <= 1 => WbElevation.level1(brightness),
      2 => WbElevation.level2(brightness),
      3 => WbElevation.level3(brightness),
      _ => WbElevation.level4(brightness),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: level == 1
            ? context.wbColors.surfaceContainer
            : context.wbColors.surfaceElevated,
        borderRadius: WbRadius.large,
        border: Border.all(color: context.wbColors.borderSubtle),
        boxShadow: shadows,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
