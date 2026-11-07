import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/components/cards/wb_tone.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbAlert extends StatelessWidget {
  const WbAlert({
    required this.title,
    required this.message,
    this.tone = WbTone.neutral,
    super.key,
  });
  final String title;
  final String message;
  final WbTone tone;
  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = _toneStyle(context, tone);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(WbSpacing.md),
        decoration: BoxDecoration(
          color: background,
          borderRadius: WbRadius.medium,
          border: Border.all(color: foreground.withValues(alpha: .45)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground, size: 24),
            const SizedBox(width: WbSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.wbText.titleMedium?.copyWith(
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message, style: context.wbText.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One-line [WbAlert] for screens read at a glance, e.g. navigation: `title:
/// message` in a single row that wraps only with large text. [slotHeight]
/// reserves room for two rows, so content below does not jump when they come
/// and go.
class WbAlertRow extends StatelessWidget {
  const WbAlertRow({
    required this.title,
    required this.message,
    this.tone = WbTone.neutral,
    super.key,
  });

  static const double minHeight = 44;
  static const double slotHeight = minHeight * 2 + WbSpacing.xs;

  final String title;
  final String message;
  final WbTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = _toneStyle(context, tone);
    return Semantics(
      liveRegion: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: WbSpacing.sm,
          vertical: WbSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: WbRadius.medium,
        ),
        child: Row(
          children: [
            Icon(icon, color: foreground, size: WbIconSize.lg),
            const SizedBox(width: WbSpacing.xs),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: context.wbText.bodyMedium,
                  children: [
                    TextSpan(
                      text: '$title: ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: message),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

(Color, Color, IconData) _toneStyle(BuildContext context, WbTone tone) {
  final colors = context.wbColors;
  return switch (tone) {
    WbTone.positive => (
      colors.positiveBg,
      colors.positive,
      Icons.check_circle_outline,
    ),
    WbTone.warning => (
      colors.warningBg.withValues(alpha: .18),
      colors.warning,
      Icons.warning_amber_rounded,
    ),
    WbTone.negative => (
      colors.negativeBg,
      colors.negative,
      Icons.error_outline,
    ),
    WbTone.brand => (
      colors.brand500.withValues(alpha: .12),
      colors.brand600,
      Icons.info_outline,
    ),
    WbTone.neutral => (
      colors.surfaceContainer,
      colors.contentSecondary,
      Icons.info_outline,
    ),
  };
}
