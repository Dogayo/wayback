import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_colors.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';

extension WbThemeContext on BuildContext {
  ThemeData get wbTheme => Theme.of(this);
  WbColors get wbColors => Theme.of(this).extension<WbColors>()!;
  TextTheme get wbText => Theme.of(this).textTheme;

  /// Padding of a scrolling screen: the content passes under the system
  /// navigation bar and ends clear of it.
  EdgeInsets get wbScrollPadding =>
      const EdgeInsets.all(WbSpacing.screenPadding).copyWith(
        bottom: WbSpacing.screenPadding + MediaQuery.paddingOf(this).bottom,
      );
}
