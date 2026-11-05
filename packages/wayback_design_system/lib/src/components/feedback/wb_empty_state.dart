import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

/// Empty-state pattern: icon, title, explanation and an optional action
/// (DESIGN_SYSTEM.md "Паттерны").
class WbEmptyState extends StatelessWidget {
  const WbEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(WbSpacing.xl),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: WbIconSize.xxl,
          color: context.wbColors.contentTertiary,
        ),
        const SizedBox(height: WbSpacing.sm),
        Text(
          title,
          style: context.wbText.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: WbSpacing.xs),
        Text(
          message,
          style: context.wbText.bodyMedium?.copyWith(
            color: context.wbColors.contentSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        if (action != null) ...[const SizedBox(height: WbSpacing.md), action!],
      ],
    ),
  );
}
