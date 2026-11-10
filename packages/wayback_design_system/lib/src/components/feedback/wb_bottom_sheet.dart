import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_elevation.dart';
import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbBottomSheet extends StatelessWidget {
  const WbBottomSheet({
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    super.key,
  });
  final String title;
  final Widget child;

  /// A line under [title].
  final String? subtitle;

  /// What the sheet is about, before [title].
  final Widget? leading;

  /// Shows [child] in a sheet that moves up with the keyboard.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required Widget child,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: context.wbColors.scrim,
    sheetAnimationStyle: AnimationStyle(
      duration: WbMotion.of(context, WbMotion.slow),
      reverseDuration: WbMotion.of(context, WbMotion.slowExit),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: WbBottomSheet(title: title, child: child),
    ),
  );
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
            child: Row(
              spacing: 12,
              children: [
                ?leading,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.wbText.titleLarge),
                      if (subtitle case final subtitle?)
                        Text(
                          subtitle,
                          style: context.wbText.bodyMedium?.copyWith(
                            color: context.wbColors.contentSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // On a short screen the rows scroll under the header.
          Flexible(child: child),
        ],
      ),
    ),
  );
}
