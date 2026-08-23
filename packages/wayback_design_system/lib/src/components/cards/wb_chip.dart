import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbChip extends StatelessWidget {
  const WbChip({
    required this.label,
    this.icon,
    this.selected = false,
    this.onSelected,
    super.key,
  });
  final String label;
  final IconData? icon;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  @override
  Widget build(BuildContext context) => FilterChip(
    selected: selected,
    onSelected: onSelected,
    showCheckmark: false,
    avatar: icon == null ? null : Icon(icon, size: 16),
    label: Text(label),
    labelStyle: context.wbText.labelMedium,
    shape: const RoundedRectangleBorder(borderRadius: WbRadius.small),
    side: BorderSide(
      color: selected
          ? context.wbColors.brand600
          : context.wbColors.borderSubtle,
      width: selected ? 2 : 1,
    ),
    backgroundColor: context.wbColors.surfaceContainer,
    selectedColor: context.wbColors.positiveBg,
  );
}
