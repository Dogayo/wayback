import 'package:flutter/material.dart';

import 'package:wayback_design_system/src/foundations/app_colors.dart';

extension WbThemeContext on BuildContext {
  ThemeData get wbTheme => Theme.of(this);
  WbColors get wbColors => Theme.of(this).extension<WbColors>()!;
  TextTheme get wbText => Theme.of(this).textTheme;
}
