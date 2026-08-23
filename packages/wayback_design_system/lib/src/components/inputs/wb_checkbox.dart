import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbCheckbox extends StatelessWidget {
  const WbCheckbox({
    required this.value,
    required this.label,
    this.onChanged,
    super.key,
  });
  final bool value;
  final String label;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: WbRadius.small,
    onTap: onChanged == null ? null : () => onChanged!(!value),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 24,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged?.call(v ?? false),
            ),
          ),
          const SizedBox(width: WbSpacing.sm),
          Expanded(child: Text(label, style: context.wbText.bodyMedium)),
        ],
      ),
    ),
  );
}
