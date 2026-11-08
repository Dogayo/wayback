import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

/// Share of the limit from which the counter is shown.
const double _counterFrom = .75;

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
    this.maxLength,
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

  /// Typing stops here; a counter appears as the limit gets close.
  final int? maxLength;

  static Widget? _counter(
    BuildContext context, {
    required int currentLength,
    required int? maxLength,
    required bool isFocused,
  }) => maxLength == null || currentLength < maxLength * _counterFrom
      ? null
      : Text(
          '$currentLength/$maxLength',
          style: context.wbText.bodySmall?.copyWith(
            color: context.wbColors.contentSecondary,
          ),
        );

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    enabled: enabled,
    obscureText: obscureText,
    maxLines: maxLines,
    minLines: minLines,
    keyboardType: keyboardType,
    maxLength: maxLength,
    buildCounter: _counter,
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
