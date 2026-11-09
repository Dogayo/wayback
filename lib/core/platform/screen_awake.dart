import 'package:flutter/services.dart';

/// Whether the display may turn off by itself; each platform implements the
/// channel in its host app.
abstract final class ScreenAwake {
  static const channel = MethodChannel('com.dogayo.wayback/screen');

  static Future<void> keepOn({required bool on}) async {
    try {
      await channel.invokeMethod<void>('keepOn', on);
    } on Exception {
      // Nothing to tell the user: the screen just dims as it always did.
    }
  }
}
