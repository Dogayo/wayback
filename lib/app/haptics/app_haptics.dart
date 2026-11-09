import 'dart:async';

import 'package:wayback/core/utils/vibration/haptic_level.dart';
import 'package:wayback/features/navigation/domain/repositories/vibration_repository.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Turns the design system's haptics into vibrations, unless the user turned
/// them off (DESIGN_SYSTEM.md, «Отклик»).
final class AppHaptics {
  AppHaptics(this._vibration, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  /// Closer than this, pulses merge into a buzz.
  static const minGap = Duration(milliseconds: 50);

  final VibrationRepository _vibration;
  final DateTime Function() _now;
  DateTime? _last;

  /// From the setting; the app updates it on each change.
  bool enabled = true;

  void play(WbHaptic haptic) {
    if (!enabled) return;
    final now = _now();
    if (_last case final last? when now.difference(last) < minGap) return;
    _last = now;
    // Nothing to tell the user: a phone that cannot vibrate just stays still.
    unawaited(_vibration.pulse(_levelOf(haptic)));
  }

  static HapticLevel _levelOf(WbHaptic haptic) => switch (haptic) {
    WbHaptic.tick => HapticLevel.tick,
    WbHaptic.press => HapticLevel.press,
    WbHaptic.success => HapticLevel.success,
    WbHaptic.warning => HapticLevel.warning,
  };
}
