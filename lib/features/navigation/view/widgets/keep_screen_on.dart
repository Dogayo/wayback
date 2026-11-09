import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wayback/core/platform/screen_awake.dart';

/// Keeps the display on while in the tree: on the way back the arrow has to
/// stay visible without touching the phone.
class KeepScreenOn extends StatefulWidget {
  const KeepScreenOn({required this.child, super.key});

  final Widget child;

  @override
  State<KeepScreenOn> createState() => _KeepScreenOnState();
}

class _KeepScreenOnState extends State<KeepScreenOn> {
  @override
  void initState() {
    super.initState();
    unawaited(ScreenAwake.keepOn(on: true));
  }

  @override
  void dispose() {
    unawaited(ScreenAwake.keepOn(on: false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
