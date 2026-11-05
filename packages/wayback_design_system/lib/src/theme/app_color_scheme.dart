import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_colors.dart';

abstract final class WbColorScheme {
  static ColorScheme light = fromColors(WbColors.light, Brightness.light);
  static ColorScheme dark = fromColors(WbColors.dark, Brightness.dark);

  static ColorScheme fromColors(WbColors colors, Brightness brightness) =>
      ColorScheme(
        brightness: brightness,
        primary: colors.actionPrimaryBg,
        onPrimary: colors.actionPrimaryFg,
        primaryContainer: colors.brand500,
        onPrimaryContainer: colors.contentOnBrand,
        secondary: colors.brand600,
        onSecondary: colors.contentOnBrand,
        secondaryContainer: colors.surfaceContainer,
        onSecondaryContainer: colors.contentPrimary,
        error: colors.negative,
        onError: colors.contentOnBrand,
        errorContainer: colors.negativeBg,
        onErrorContainer: colors.negative,
        surface: colors.surfaceDefault,
        onSurface: colors.contentPrimary,
        surfaceContainerHighest: colors.surfaceContainer,
        onSurfaceVariant: colors.contentSecondary,
        outline: colors.borderDefault,
        outlineVariant: colors.borderSubtle,
        shadow: WbPalette.black,
        scrim: colors.scrim,
        inverseSurface: colors.contentPrimary,
        onInverseSurface: colors.surfaceDefault,
        inversePrimary: colors.brand500,
      );
}
