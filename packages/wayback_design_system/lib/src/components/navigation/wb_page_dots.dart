import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

/// Position in a short sequence of pages, e.g. onboarding steps: the
/// current page is a wider accent pill, the others are dots.
class WbPageDots extends StatelessWidget {
  const WbPageDots({
    required this.count,
    required this.index,
    this.semanticLabel,
    super.key,
  });

  final int count;
  final int index;

  /// E.g. «Шаг 2 из 3»; the dots alone say nothing to a screen reader.
  final String? semanticLabel;

  static const _dot = 8.0;
  static const _active = 24.0;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    child: ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: WbSpacing.xs),
            AnimatedContainer(
              duration: WbMotion.base,
              curve: WbMotion.easeOut,
              width: i == index ? _active : _dot,
              height: _dot,
              decoration: BoxDecoration(
                color: i == index
                    ? context.wbColors.brand600
                    : context.wbColors.borderSubtle,
                borderRadius: BorderRadius.circular(_dot / 2),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
