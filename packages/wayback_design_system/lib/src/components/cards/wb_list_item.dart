import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_haptics.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

/// A full-width row: 16 dp from the screen edge, 56 dp tall, 72 dp with a
/// subtitle. Without [leading] the title reads as a plain setting.
///
/// [selected] marks a chosen option with a brand check instead of [trailing].
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

  /// Where the divider starts beside a 40 dp leading tile.
  static const double _leadingInset = WbSpacing.md * 2 + 40;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Semantics(
        selected: selected,
        button: onTap != null,
        child: InkWell(
          onTap: onTap,
          // The system's own long press answer would come on top of ours.
          enableFeedback: onLongPress == null,
          onLongPress: onLongPress == null
              ? null
              : () {
                  WbHaptics.play(context, WbHaptic.press);
                  onLongPress!();
                },
          child: Container(
            constraints: BoxConstraints(minHeight: subtitle == null ? 56 : 72),
            padding: const EdgeInsets.symmetric(
              horizontal: WbSpacing.md,
              vertical: WbSpacing.sm,
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: WbSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: leading == null
                            ? context.wbText.bodyLarge
                            : context.wbText.titleMedium,
                      ),
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
                if (selected || trailing != null) ...[
                  const SizedBox(width: WbSpacing.sm),
                  if (selected)
                    Icon(Icons.check, color: context.wbColors.brand600)
                  else
                    trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
      if (showDivider)
        Divider(
          indent: leading == null ? WbSpacing.md : _leadingInset,
          endIndent: WbSpacing.md,
        ),
    ],
  );
}
