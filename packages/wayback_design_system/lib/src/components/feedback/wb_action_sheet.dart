import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/components/feedback/wb_bottom_sheet.dart';
import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

/// One row of a [WbActionSheet].
class WbSheetAction {
  const WbSheetAction({
    required this.icon,
    required this.label,
    required this.onSelected,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onSelected;
  final bool destructive;
}

const double _rowHeight = 56;
const double _tileSize = 40;

/// What can be done with one thing, as a sheet from the bottom of the
/// screen: within reach of the thumb on both platforms.
abstract final class WbActionSheet {
  /// Runs the chosen action as soon as the sheet is dismissed.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<WbSheetAction> actions,
    String? subtitle,
  }) async {
    final action = await showModalBottomSheet<WbSheetAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: context.wbColors.scrim,
      sheetAnimationStyle: AnimationStyle(
        duration: WbMotion.of(context, WbMotion.slow),
        reverseDuration: WbMotion.of(context, WbMotion.slowExit),
      ),
      builder: (context) => WbBottomSheet(
        title: title,
        subtitle: subtitle,
        leading: _Tile(icon),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                height: 1,
                thickness: 1,
                color: context.wbColors.borderSubtle,
              ),
              for (final action in actions)
                _Row(action, onTap: () => Navigator.pop(context, action)),
              const SizedBox(height: WbSpacing.sm),
            ],
          ),
        ),
      ),
    );
    action?.onSelected();
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: _tileSize,
    height: _tileSize,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.wbColors.surfaceContainer,
      shape: BoxShape.circle,
    ),
    child: Icon(
      icon,
      size: WbIconSize.md,
      color: context.wbColors.contentSecondary,
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row(this.action, {required this.onTap});

  final WbSheetAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = action.destructive
        ? context.wbColors.negative
        : context.wbColors.contentPrimary;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _rowHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: WbSpacing.md),
            child: Row(
              spacing: WbSpacing.md,
              children: [
                Icon(action.icon, size: WbIconSize.lg, color: color),
                Expanded(
                  child: Text(
                    action.label,
                    style: context.wbText.bodyLarge?.copyWith(color: color),
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
