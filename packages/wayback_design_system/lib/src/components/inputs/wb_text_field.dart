import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbTextField extends StatelessWidget {
  const WbTextField({
    this.controller,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.leadingIcon,
    this.trailing,
    this.onChanged,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    super.key,
  });
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final IconData? leadingIcon;
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    enabled: enabled,
    obscureText: obscureText,
    maxLines: maxLines,
    minLines: minLines,
    keyboardType: keyboardType,
    onChanged: onChanged,
    style: context.wbText.bodyLarge,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      errorText: error,
      prefixIcon: leadingIcon == null
          ? null
          : Icon(leadingIcon, size: WbIconSize.md),
      suffixIcon: trailing,
      alignLabelWithHint: (maxLines ?? 1) > 1,
    ),
  );
}
