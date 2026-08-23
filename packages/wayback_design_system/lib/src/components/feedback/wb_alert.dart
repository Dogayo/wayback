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
    final colors = context.wbColors;
    final (background, foreground, icon) = switch (tone) {
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
