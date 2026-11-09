import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_haptics.dart';
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
    final isApple =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final control = isApple
        // CupertinoSwitch gives its own tap on iOS.
        ? CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: context.wbColors.actionPrimaryBg,
          )
        : Switch(
            value: value,
            onChanged: onChanged == null
                ? null
                : (changed) {
                    WbHaptics.play(context, WbHaptic.tick);
                    onChanged!(changed);
                  },
          );
    return Row(
      children: [
        Expanded(child: Text(label, style: context.wbText.bodyMedium)),
        control,
      ],
    );
  }
}
