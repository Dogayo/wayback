import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbListItem extends StatelessWidget {
  const WbListItem({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.selected = false,
    this.showDivider = false,
    this.onTap,
    this.onLongPress,
    super.key,
  });
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
  final bool showDivider;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Semantics(
        selected: selected,
        button: onTap != null,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: WbRadius.medium,
          child: AnimatedContainer(
            duration: WbMotion.of(context, WbMotion.fast),
            curve: WbMotion.standard,
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? context.wbColors.positiveBg
                  : Colors.transparent,
              borderRadius: WbRadius.medium,
              border: selected
                  ? Border.all(color: context.wbColors.positive)
                  : null,
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: WbSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: context.wbText.titleMedium),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: context.wbText.bodyMedium?.copyWith(
                            color: context.wbColors.contentSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: WbSpacing.sm),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
      if (showDivider) const Divider(indent: 12, endIndent: 12),
    ],
  );
}
