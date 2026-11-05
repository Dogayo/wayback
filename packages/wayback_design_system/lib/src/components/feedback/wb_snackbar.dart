import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_elevation.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbSnackbar extends StatelessWidget {
  const WbSnackbar({
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Shows [message] at the bottom of the nearest Scaffold, replacing the
  /// current snackbar. The look comes from the theme's snackBarTheme.
  static void show(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 52),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: context.wbColors.surfaceElevated,
      borderRadius: WbRadius.medium,
      border: Border.all(color: context.wbColors.borderSubtle),
      boxShadow: WbElevation.level3(Theme.of(context).brightness),
    ),
    child: Row(
      children: [
        Expanded(child: Text(message, style: context.wbText.bodyMedium)),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    ),
  );
}
