import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

enum WbIconButtonVariant { ghost, brand, filled, negative }

class WbIconButton extends StatelessWidget {
  const WbIconButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.variant = WbIconButtonVariant.ghost,
    super.key,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final WbIconButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
    final foreground = switch (variant) {
      WbIconButtonVariant.brand => colors.contentOnBrand,
      WbIconButtonVariant.negative => colors.negative,
      _ => colors.contentPrimary,
    };
    final background = switch (variant) {
      WbIconButtonVariant.brand => colors.actionPrimaryBg,
      WbIconButtonVariant.filled => colors.surfaceContainer,
      WbIconButtonVariant.negative => colors.negativeBg,
      WbIconButtonVariant.ghost => Colors.transparent,
    };
    return Semantics(
      button: true,
      label: label,
      child: IconButton(
        onPressed: onPressed,
        tooltip: label,
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        style: IconButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
        ),
        icon: Icon(icon, size: WbIconSize.lg),
      ),
    );
  }
}
