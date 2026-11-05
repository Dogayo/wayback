import 'package:flutter/widgets.dart';

abstract final class WbRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double full = 999;
  static const double dialogAndroid = 28;

  static const BorderRadius small = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(md));
  static const BorderRadius large = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(full));
}

abstract final class WbBorder {
  static const double thin = 1;
  static const double thick = 2;
}

abstract final class WbIconSize {
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
