import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/components/navigation/wb_back_button.dart';

class WbAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WbAppBar({
    required this.title,
    this.onBack,
    this.actions = const [],
    super.key,
  });
  final String title;
  final VoidCallback? onBack;
  final List<Widget> actions;
  @override
  Size get preferredSize => const Size.fromHeight(56);
  @override
  Widget build(BuildContext context) => AppBar(
    leading: onBack == null ? null : WbBackButton(onPressed: onBack),
    automaticallyImplyLeading: false,
    title: Text(title),
    actions: actions,
  );
}
