import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbSwitch extends StatelessWidget {
  const WbSwitch({
    required this.value,
    required this.label,
    this.onChanged,
    super.key,
  });
  final bool value;
  final String label;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final control =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
        ? CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: context.wbColors.actionPrimaryBg,
          )
        : Switch(value: value, onChanged: onChanged);
    return Row(
      children: [
        Expanded(child: Text(label, style: context.wbText.bodyMedium)),
        control,
      ],
    );
  }
}
