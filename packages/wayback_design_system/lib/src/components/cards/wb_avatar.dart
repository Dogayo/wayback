import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

class WbAvatar extends StatelessWidget {
  const WbAvatar({
    required this.name,
    this.size = 40,
    this.brand = false,
    super.key,
  });
  final String name;
  final double size;
  final bool brand;
  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: name,
    child: CircleAvatar(
      radius: size / 2,
      backgroundColor: brand
          ? context.wbColors.brand600
          : context.wbColors.surfaceSunken,
      foregroundColor: brand
          ? context.wbColors.contentOnBrand
          : context.wbColors.contentPrimary,
      child: Text(
        name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase(),
        style: context.wbText.titleMedium?.copyWith(
          color: brand
              ? context.wbColors.contentOnBrand
              : context.wbColors.contentPrimary,
        ),
      ),
    ),
  );
}
