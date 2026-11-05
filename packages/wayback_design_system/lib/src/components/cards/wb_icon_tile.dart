import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

/// A round tile with one icon, e.g. the point type beside its name.
class WbIconTile extends StatelessWidget {
  const WbIconTile({required this.icon, super.key});
  final IconData icon;

  /// Diameter: the 48 dp touch-size step plus room for the 32 dp glyph.
  static const double size = WbSpacing.xxxxl + WbSpacing.xs;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.wbColors.surfaceContainer,
      shape: BoxShape.circle,
    ),
    child: Icon(
      icon,
      size: WbIconSize.xl,
      color: context.wbColors.contentSecondary,
    ),
  );
}
