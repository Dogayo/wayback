import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

const double _trackHeight = 44;
const double _inset = 4;

/// One choice out of a few, as equal segments in a track; the chosen one is
/// a raised plate inside it.
///
/// The whole height of a segment takes the tap, so the target stays 44 even
/// though the plate is smaller. Labels wrap with large text instead of
/// being cut off.
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
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: _trackHeight),
    padding: const EdgeInsets.symmetric(horizontal: _inset),
    decoration: BoxDecoration(
      color: context.wbColors.segmentTrack,
      borderRadius: WbRadius.medium,
    ),
    child: IntrinsicHeight(
      child: Row(
        spacing: _inset,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final MapEntry(key: item, value: label) in items.entries)
            Expanded(
              child: _Segment(
                label: label,
                selected: item == value,
                onTap: () => onChanged(item),
              ),
            ),
        ],
      ),
    ),
  );
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    inMutuallyExclusiveGroup: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: selected ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: _inset),
        child: AnimatedContainer(
          duration: WbMotion.fast,
          curve: WbMotion.standard,
          alignment: Alignment.center,
          constraints: const BoxConstraints(
            minHeight: _trackHeight - _inset * 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: _inset * 2,
            vertical: _inset,
          ),
          decoration: BoxDecoration(
            color: selected
                ? context.wbColors.segmentSelected
                : Colors.transparent,
            borderRadius: WbRadius.small,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.wbText.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: context.wbColors.contentPrimary,
            ),
          ),
        ),
      ),
    ),
  );
}
