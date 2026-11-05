import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbRadio<T> extends StatelessWidget {
  const WbRadio({
    required this.value,
    required this.groupValue,
    required this.label,
    this.onChanged,
    super.key,
  });
  final T value;
  final T? groupValue;
  final String label;
  final ValueChanged<T>? onChanged;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: WbRadius.small,
    onTap: onChanged == null ? null : () => onChanged!(value),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 24,
            child: RadioGroup<T>(
              groupValue: groupValue,
              onChanged: (v) {
                if (v != null) onChanged?.call(v);
              },
              child: Radio<T>(value: value),
            ),
          ),
          const SizedBox(width: WbSpacing.sm),
          Expanded(child: Text(label, style: context.wbText.bodyMedium)),
        ],
      ),
    ),
  );
}
