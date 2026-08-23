import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_colors.dart';
import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/foundations/app_radius.dart';
import 'package:wayback_design_system/src/foundations/app_typography.dart';
import 'package:wayback_design_system/src/theme/app_color_scheme.dart';

abstract final class WbTheme {
  static ThemeData get light => _build(Brightness.light, WbColors.light);
  static ThemeData get dark => _build(Brightness.dark, WbColors.dark);

  static ThemeData _build(Brightness brightness, WbColors colors) {
    final scheme = WbColorScheme.fromColors(colors, brightness);
    final textTheme = WbTypography.textTheme(colors.contentPrimary);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.surfaceDefault,
      textTheme: textTheme,
      extensions: [colors],
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: DividerThemeData(
        color: colors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.brand600,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: const OutlineInputBorder(borderRadius: WbRadius.medium),
        enabledBorder: OutlineInputBorder(
          borderRadius: WbRadius.medium,
          borderSide: BorderSide(color: colors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: WbRadius.medium,
          borderSide: BorderSide(color: colors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: WbRadius.medium,
          borderSide: BorderSide(color: colors.negative),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: WbRadius.medium,
          borderSide: BorderSide(color: colors.negative, width: 2),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colors.contentSecondary,
        ),
        helperStyle: textTheme.bodySmall?.copyWith(
          color: colors.contentTertiary,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(color: colors.negative),
        hintStyle: textTheme.bodyLarge?.copyWith(color: colors.contentTertiary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surfaceDefault,
        foregroundColor: colors.contentPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 56,
        titleTextStyle: textTheme.titleMedium,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium,
        actionTextColor: colors.brand600,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: WbRadius.medium,
          side: BorderSide(color: colors.borderSubtle),
        ),
      ),
      tooltipTheme: const TooltipThemeData(waitDuration: WbMotion.fast),
    );
  }
}
