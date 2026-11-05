import 'package:flutter/material.dart';

/// Примитивы палитры.
///
/// Нейтральные — холодный сине-серый, hue 215° («анодированный алюминий»),
/// бренд — оранжевый, hue 26°. Бренд удерживается на 15–20° от warning (42°)
/// и negative (4°), чтобы статусные цвета никогда не читались как брендовые.
///
/// Компоненты примитивы не используют: они читают семантические токены из
/// [WbColors]. Примитивы существуют только для того, чтобы собирать из них
/// семантику.
abstract final class WbPalette {
  // --- neutral ---
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF5F7F9);
  static const Color neutral100 = Color(0xFFEAEDF1);
  static const Color neutral200 = Color(0xFFDDE2E7);
  static const Color neutral300 = Color(0xFFAEB8C2);
  static const Color neutral400 = Color(0xFF8A97A3);
  static const Color neutral500 = Color(0xFF6B7885);
  static const Color neutral600 = Color(0xFF545F6B);
  static const Color neutral700 = Color(0xFF2B3138);
  static const Color neutral800 = Color(0xFF1B2025);
  static const Color neutral900 = Color(0xFF14181D);
  static const Color neutral1000 = Color(0xFF0B0D10);

  // --- brand ---
  static const Color brand50 = Color(0xFFFFF1E6);
  static const Color brand300 = Color(0xFFF97A2E);
  static const Color brand500 = Color(0xFFE2591A);
  static const Color brand600 = Color(0xFFC24812);
  static const Color brand700 = Color(0xFF9E390D);

  // --- status ---
  static const Color green500 = Color(0xFF1E8E5A);
  static const Color green400 = Color(0xFF34A873);
  static const Color green50 = Color(0xFFE6F4EC);
  static const Color green900 = Color(0xFF10261C);
  static const Color amber700 = Color(0xFF8F5B08);
  static const Color amber600 = Color(0xFFB8790A);
  static const Color amber400 = Color(0xFFE0A030);
  static const Color red500 = Color(0xFFD53A2E);
  static const Color red400 = Color(0xFFFF6E5E);
  static const Color red50 = Color(0xFFFBE9E7);
  static const Color red900 = Color(0xFF331410);

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
}

/// Семантические цвета — единственное, что читают компоненты.
///
/// Светлая и тёмная схемы — два независимых отображения одних и тех же имён.
/// Компонент спрашивает `surfaceDefault`, он никогда не спрашивает
/// «сейчас тёмная тема?».
@immutable
class WbColors extends ThemeExtension<WbColors> {
  const WbColors({
    required this.brand500,
    required this.brand600,
    required this.surfaceDefault,
    required this.surfaceElevated,
    required this.surfaceContainer,
    required this.surfaceSunken,
    required this.contentPrimary,
    required this.contentSecondary,
    required this.contentTertiary,
    required this.contentDisabled,
    required this.contentOnBrand,
    required this.borderDefault,
    required this.borderSubtle,
    required this.borderFocus,
    required this.actionPrimaryBg,
    required this.actionPrimaryFg,
    required this.actionPrimaryPressed,
    required this.actionSecondaryBorder,
    required this.actionSecondaryFg,
    required this.positive,
    required this.positiveBg,
    required this.warning,
    required this.warningBg,
    required this.warningInk,
    required this.negative,
    required this.negativeBg,
    required this.scrim,
  });

  final Color brand500;
  final Color brand600;

  final Color surfaceDefault;
  final Color surfaceElevated;
  final Color surfaceContainer;
  final Color surfaceSunken;

  final Color contentPrimary;
  final Color contentSecondary;
  final Color contentTertiary;
  final Color contentDisabled;
  final Color contentOnBrand;

  final Color borderDefault;
  final Color borderSubtle;
  final Color borderFocus;

  final Color actionPrimaryBg;
  final Color actionPrimaryFg;
  final Color actionPrimaryPressed;
  final Color actionSecondaryBorder;
  final Color actionSecondaryFg;

  final Color positive;
  final Color positiveBg;
  final Color warning;

  /// Заливка для акцентных предупреждений. Используется с прозрачностью:
  /// сплошной амбер слишком тяжёл под текстом.
  final Color warningBg;

  /// Текст поверх сплошной заливки [warningBg].
  final Color warningInk;

  final Color negative;
  final Color negativeBg;

  /// Затемнение под модальными слоями: 48 % чернил в светлой, 64 % чёрного в тёмной.
  final Color scrim;

  static const WbColors light = WbColors(
    brand500: Color(0xFFE2591A),
    brand600: Color(0xFFC24812),
    surfaceDefault: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFF5F7F9),
    surfaceSunken: Color(0xFFEAEDF1),
    contentPrimary: Color(0xFF1B2025),
    contentSecondary: Color(0xFF545F6B),
    contentTertiary: Color(0xFF6B7885),
    contentDisabled: Color(0xFFAEB8C2),
    contentOnBrand: Color(0xFFFFFFFF),
    borderDefault: Color(0xFF6B7885),
    borderSubtle: Color(0xFFDDE2E7),
    borderFocus: Color(0xFFC24812),
    actionPrimaryBg: Color(0xFFC24812),
    actionPrimaryFg: Color(0xFFFFFFFF),
    actionPrimaryPressed: Color(0xFF9E390D),
    actionSecondaryBorder: Color(0xFF6B7885),
    actionSecondaryFg: Color(0xFF1B2025),
    positive: Color(0xFF1E8E5A),
    positiveBg: Color(0xFFE6F4EC),
    warning: Color(0xFF8F5B08),
    warningBg: Color(0xFFB8790A),
    warningInk: Color(0xFF1B2025),
    negative: Color(0xFFD53A2E),
    negativeBg: Color(0xFFFBE9E7),
    scrim: Color(0x7A14181D),
  );

  static const WbColors dark = WbColors(
    brand500: Color(0xFFF97A2E),
    brand600: Color(0xFFF97A2E),
    surfaceDefault: Color(0xFF0B0D10),
    surfaceElevated: Color(0xFF1B2025),
    surfaceContainer: Color(0xFF14181D),
    surfaceSunken: Color(0xFF000000),
    contentPrimary: Color(0xFFF5F7F9),
    contentSecondary: Color(0xFFAEB8C2),
    contentTertiary: Color(0xFF8A97A3),
    contentDisabled: Color(0xFF545F6B),
    contentOnBrand: Color(0xFFFFFFFF),
    borderDefault: Color(0xFF6B7885),
    borderSubtle: Color(0xFF2B3138),
    borderFocus: Color(0xFFF97A2E),
    actionPrimaryBg: Color(0xFFC24812),
    actionPrimaryFg: Color(0xFFFFFFFF),
    actionPrimaryPressed: Color(0xFF9E390D),
    actionSecondaryBorder: Color(0xFF6B7885),
    actionSecondaryFg: Color(0xFFF5F7F9),
    positive: Color(0xFF34A873),
    positiveBg: Color(0xFF10261C),
    warning: Color(0xFFE0A030),
    warningBg: Color(0xFFB8790A),
    warningInk: Color(0xFF1B2025),
    negative: Color(0xFFFF6E5E),
    negativeBg: Color(0xFF331410),
    scrim: Color(0xA3000000),
  );

  @override
  WbColors copyWith({
    Color? brand500,
    Color? brand600,
    Color? surfaceDefault,
    Color? surfaceElevated,
    Color? surfaceContainer,
    Color? surfaceSunken,
    Color? contentPrimary,
    Color? contentSecondary,
    Color? contentTertiary,
    Color? contentDisabled,
    Color? contentOnBrand,
    Color? borderDefault,
    Color? borderSubtle,
    Color? borderFocus,
    Color? actionPrimaryBg,
    Color? actionPrimaryFg,
    Color? actionPrimaryPressed,
    Color? actionSecondaryBorder,
    Color? actionSecondaryFg,
    Color? positive,
    Color? positiveBg,
    Color? warning,
    Color? warningBg,
    Color? warningInk,
    Color? negative,
    Color? negativeBg,
    Color? scrim,
  }) {
    return WbColors(
      brand500: brand500 ?? this.brand500,
      brand600: brand600 ?? this.brand600,
      surfaceDefault: surfaceDefault ?? this.surfaceDefault,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      contentPrimary: contentPrimary ?? this.contentPrimary,
      contentSecondary: contentSecondary ?? this.contentSecondary,
      contentTertiary: contentTertiary ?? this.contentTertiary,
      contentDisabled: contentDisabled ?? this.contentDisabled,
      contentOnBrand: contentOnBrand ?? this.contentOnBrand,
      borderDefault: borderDefault ?? this.borderDefault,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderFocus: borderFocus ?? this.borderFocus,
      actionPrimaryBg: actionPrimaryBg ?? this.actionPrimaryBg,
      actionPrimaryFg: actionPrimaryFg ?? this.actionPrimaryFg,
      actionPrimaryPressed: actionPrimaryPressed ?? this.actionPrimaryPressed,
      actionSecondaryBorder:
          actionSecondaryBorder ?? this.actionSecondaryBorder,
      actionSecondaryFg: actionSecondaryFg ?? this.actionSecondaryFg,
      positive: positive ?? this.positive,
      positiveBg: positiveBg ?? this.positiveBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      warningInk: warningInk ?? this.warningInk,
      negative: negative ?? this.negative,
      negativeBg: negativeBg ?? this.negativeBg,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  WbColors lerp(covariant WbColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return WbColors(
      brand500: c(brand500, other.brand500),
      brand600: c(brand600, other.brand600),
      surfaceDefault: c(surfaceDefault, other.surfaceDefault),
      surfaceElevated: c(surfaceElevated, other.surfaceElevated),
      surfaceContainer: c(surfaceContainer, other.surfaceContainer),
      surfaceSunken: c(surfaceSunken, other.surfaceSunken),
      contentPrimary: c(contentPrimary, other.contentPrimary),
      contentSecondary: c(contentSecondary, other.contentSecondary),
      contentTertiary: c(contentTertiary, other.contentTertiary),
      contentDisabled: c(contentDisabled, other.contentDisabled),
      contentOnBrand: c(contentOnBrand, other.contentOnBrand),
      borderDefault: c(borderDefault, other.borderDefault),
      borderSubtle: c(borderSubtle, other.borderSubtle),
      borderFocus: c(borderFocus, other.borderFocus),
      actionPrimaryBg: c(actionPrimaryBg, other.actionPrimaryBg),
      actionPrimaryFg: c(actionPrimaryFg, other.actionPrimaryFg),
      actionPrimaryPressed: c(actionPrimaryPressed, other.actionPrimaryPressed),
      actionSecondaryBorder: c(
        actionSecondaryBorder,
        other.actionSecondaryBorder,
      ),
      actionSecondaryFg: c(actionSecondaryFg, other.actionSecondaryFg),
      positive: c(positive, other.positive),
      positiveBg: c(positiveBg, other.positiveBg),
      warning: c(warning, other.warning),
      warningBg: c(warningBg, other.warningBg),
      warningInk: c(warningInk, other.warningInk),
      negative: c(negative, other.negative),
      negativeBg: c(negativeBg, other.negativeBg),
      scrim: c(scrim, other.scrim),
    );
  }
}
