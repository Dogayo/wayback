import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

/// A round tile with one icon, e.g. the point type beside its name.
class WbIconTile extends StatelessWidget {
  const WbIconTile({required this.icon, this.compact = false, super.key});
  final IconData icon;

  /// The size for a list row.
  final bool compact;

  /// Diameter: the 48 dp touch-size step plus room for the 32 dp glyph.
  static const double size = WbSpacing.xxxxl + WbSpacing.xs;
  static const double compactSize = WbSpacing.xxxl;

  @override
  Widget build(BuildContext context) => Container(
    width: compact ? compactSize : size,
    height: compact ? compactSize : size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.wbColors.surfaceContainer,
      shape: BoxShape.circle,
    ),
    child: Icon(
      icon,
      size: compact ? WbIconSize.md : WbIconSize.xl,
      color: context.wbColors.contentSecondary,
    ),
  );
}
