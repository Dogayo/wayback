import 'package:flutter/material.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Pinned bar under the content with the screen's main actions.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.wbColors.surfaceElevated,
      border: Border(top: BorderSide(color: context.wbColors.borderSubtle)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(WbSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: WbSpacing.xs,
          children: children,
        ),
      ),
    ),
  );
}
