import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/components/cards/wb_tone.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbBadge extends StatelessWidget {
  const WbBadge({required this.label, this.tone = WbTone.neutral, super.key});
  final String label;
  final WbTone tone;
  @override
  Widget build(BuildContext context) {
    final colors = context.wbColors;
    final (background, foreground) = switch (tone) {
      WbTone.brand => (colors.brand600, colors.contentOnBrand),
      WbTone.positive => (colors.positiveBg, colors.positive),
      WbTone.warning => (colors.warningBg, colors.warningInk),
      WbTone.negative => (colors.negativeBg, colors.negative),
      WbTone.neutral => (colors.surfaceContainer, colors.contentSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: WbRadius.small,
      ),
      child: Text(
        label,
        style: context.wbText.labelMedium?.copyWith(
          color: foreground,
          fontSize: 12,
        ),
      ),
    );
  }
}
