import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/components/inputs/wb_point_type.dart';
import 'package:wayback_design_system/src/foundations/app_haptics.dart';
import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbTypePicker extends StatelessWidget {
  const WbTypePicker({
    required this.value,
    required this.onChanged,
    this.labelOf,
    super.key,
  });
  final WbPointType value;
  final ValueChanged<WbPointType> onChanged;

  /// Localized tile label; defaults to [WbPointTypeData.label].
  final String Function(WbPointType type)? labelOf;
  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 4,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: WbSpacing.sm,
    crossAxisSpacing: WbSpacing.sm,
    childAspectRatio: 1,
    children: [
      for (final type in WbPointType.values)
        _TypeTile(
          type: type,
          label: labelOf?.call(type) ?? type.label,
          selected: type == value,
          onTap: () => onChanged(type),
        ),
    ],
  );
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.type,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final WbPointType type;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    label: label,
    child: InkWell(
      key: ValueKey('wb-type-${type.name}'),
      onTap: () {
        if (!selected) WbHaptics.play(context, WbHaptic.tick);
        onTap();
      },
      borderRadius: WbRadius.medium,
      child: AnimatedContainer(
        duration: WbMotion.of(context, WbMotion.fast),
        curve: WbMotion.standard,
        decoration: BoxDecoration(
          // actionPrimaryBg, not brand600: the dark brand600 is too light
          // for white text (2.6:1), the action fill stays at 4.97:1.
          color: selected
              ? context.wbColors.actionPrimaryBg
              : Colors.transparent,
          borderRadius: WbRadius.medium,
          border: Border.all(
            color: selected
                ? context.wbColors.actionPrimaryBg
                : context.wbColors.borderSubtle,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type.icon,
              size: WbIconSize.lg,
              color: selected
                  ? context.wbColors.actionPrimaryFg
                  : context.wbColors.contentSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.wbText.labelMedium?.copyWith(
                color: selected
                    ? context.wbColors.actionPrimaryFg
                    : context.wbColors.contentSecondary,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
