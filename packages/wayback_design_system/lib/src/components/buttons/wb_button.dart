import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

enum WbButtonVariant { primary, secondary, tertiary, destructive }

enum WbButtonSize { small, medium }

class WbButton extends StatelessWidget {
  const WbButton({
    required this.label,
    this.onPressed,
    this.variant = WbButtonVariant.primary,
    this.size = WbButtonSize.medium,
    this.icon,
    this.loading = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final WbButtonVariant variant;
  final WbButtonSize size;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
    final enabled = onPressed != null && !loading;
    final foreground = switch (variant) {
      WbButtonVariant.primary => colors.actionPrimaryFg,
      WbButtonVariant.secondary => colors.actionSecondaryFg,
      WbButtonVariant.tertiary => colors.brand600,
      WbButtonVariant.destructive => colors.negative,
    };
    final background = variant == WbButtonVariant.primary
        ? colors.actionPrimaryBg
        : Colors.transparent;
    final border = switch (variant) {
      WbButtonVariant.secondary => colors.actionSecondaryBorder,
      WbButtonVariant.destructive => colors.negative,
      _ => Colors.transparent,
    };
    final height = size == WbButtonSize.small ? 36.0 : WbSpacing.tapTarget;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: enabled ? 1 : .6,
        child: SizedBox(
          height: height,
          child: TextButton(
            onPressed: enabled ? onPressed : null,
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(
                  horizontal: size == WbButtonSize.small ? 12 : 16,
                ),
              ),
              minimumSize: WidgetStatePropertyAll(Size(0, height)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: WbRadius.medium,
                  side: BorderSide(color: border),
                ),
              ),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed) &&
                    variant == WbButtonVariant.primary) {
                  return colors.actionPrimaryPressed;
                }
                return background;
              }),
              foregroundColor: WidgetStatePropertyAll(foreground),
              overlayColor: WidgetStatePropertyAll(
                foreground.withValues(alpha: .08),
              ),
              textStyle: WidgetStatePropertyAll(context.wbText.labelLarge),
            ),
            // The label stays laid out under the spinner, so the button
            // keeps its width while loading.
            child: Stack(
              alignment: Alignment.center,
              children: [
                _Fade(
                  visible: !loading,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: WbIconSize.md),
                        const SizedBox(width: WbSpacing.xs),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ],
                  ),
                ),
                _Fade(
                  visible: loading,
                  child: SizedBox.square(
                    dimension: 18,
                    // A hidden spinner stands still instead of ticking.
                    child: CircularProgressIndicator(
                      value: loading ? null : 0,
                      strokeWidth: 2,
                      color: foreground,
                      semanticsLabel: loading ? label : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades the label and the spinner past each other (05 · Motion,
/// «WbButton · загрузка»): out over the first 40%, in from 27%.
class _Fade extends StatelessWidget {
  const _Fade({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: visible ? 1 : 0,
    duration: WbMotion.of(context, WbMotion.fast),
    curve: visible
        ? const Interval(60 / 220, 1, curve: WbMotion.easeOut)
        : const Interval(0, .4, curve: WbMotion.accelerate),
    child: ExcludeSemantics(excluding: !visible, child: child),
  );
}
