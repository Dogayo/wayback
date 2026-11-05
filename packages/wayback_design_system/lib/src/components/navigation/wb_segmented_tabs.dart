import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbSegmentedTabs<T> extends StatelessWidget {
  const WbSegmentedTabs({
    required this.items,
    required this.value,
    required this.onChanged,
    super.key,
  });
  final Map<T, String> items;
  final T value;
  final ValueChanged<T> onChanged;
  @override
  Widget build(BuildContext context) => SegmentedButton<T>(
    segments: [
      for (final entry in items.entries)
        ButtonSegment(value: entry.key, label: Text(entry.value)),
    ],
    selected: {value},
    onSelectionChanged: (selection) => onChanged(selection.first),
    showSelectedIcon: false,
    style: ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12),
      ),
      textStyle: WidgetStatePropertyAll(context.wbText.labelMedium),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: WbRadius.small),
      ),
    ),
  );
}
