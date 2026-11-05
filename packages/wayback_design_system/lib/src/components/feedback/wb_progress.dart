import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbProgress extends StatelessWidget {
  const WbProgress({required this.label, this.value, super.key});
  final String label;
  final double? value;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    value: value == null ? null : '${(value! * 100).round()}%',
    child: Row(
      children: [
        SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(value: value, strokeWidth: 2.5),
        ),
        const SizedBox(width: WbSpacing.sm),
        Expanded(child: Text(label, style: context.wbText.bodyMedium)),
        if (value != null)
          Text('${(value! * 100).round()}%', style: context.wbText.bodySmall),
      ],
    ),
  );
}
