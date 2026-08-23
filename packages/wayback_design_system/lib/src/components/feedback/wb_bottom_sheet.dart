import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_elevation.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbBottomSheet extends StatelessWidget {
  const WbBottomSheet({required this.title, required this.child, super.key});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.wbColors.surfaceElevated,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(WbRadius.lg),
      ),
      boxShadow: WbElevation.level4(Theme.of(context).brightness),
    ),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.wbColors.borderDefault,
              borderRadius: WbRadius.pill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: context.wbText.titleLarge),
            ),
          ),
          child,
        ],
      ),
    ),
  );
}
