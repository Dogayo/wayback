import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wayback_design_system/src/components/navigation/wb_back_button.dart';

class WbAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WbAppBar({
    required this.title,
    this.onBack,
    this.actions = const [],
    this.onField,
    super.key,
  });
  final String title;
  final VoidCallback? onBack;
  final List<Widget> actions;

  /// Content colour when the bar sits on a coloured field: the bar itself
  /// turns transparent and the status bar icons follow this colour.
  final Color? onField;
  @override
  Size get preferredSize => const Size.fromHeight(56);
  @override
  Widget build(BuildContext context) {
    final field = onField;
    return AppBar(
      leading: onBack == null ? null : WbBackButton(onPressed: onBack),
      automaticallyImplyLeading: false,
      title: Text(title),
      actions: actions,
      backgroundColor: field == null ? null : Colors.transparent,
      foregroundColor: field,
      titleTextStyle: field == null
          ? null
          : Theme.of(context).textTheme.titleMedium?.copyWith(color: field),
      systemOverlayStyle: field == null
          ? null
          : ThemeData.estimateBrightnessForColor(field) == Brightness.light
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }
}
