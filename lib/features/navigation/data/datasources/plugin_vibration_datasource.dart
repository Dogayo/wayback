import 'dart:io';

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:wayback/core/utils/vibration/haptic_level.dart';
import 'package:wayback/core/utils/vibration/vibration_pattern.dart';
import 'package:wayback/features/navigation/data/datasources/vibration_datasource.dart';

/// The vibrator itself, not `HapticFeedback`: touch feedback stayed silent
/// on a Samsung M32 in the field check, and it is meant for taps anyway.
final class PluginVibrationDatasource implements VibrationDatasource {
  const PluginVibrationDatasource();

  static const _maxAmplitude = 255;

  @override
  Future<void> vibrate(VibrationPattern pattern) => switch (pattern) {
    VibrationPattern.standard => Vibration.vibrate(duration: 400),
    VibrationPattern.long => Vibration.vibrate(duration: 1000),
    VibrationPattern.twice => Vibration.vibrate(pattern: [0, 400, 200, 400]),
    // Phones without amplitude control ignore the intensities.
    VibrationPattern.strong => Vibration.vibrate(
      pattern: [0, 800, 150, 800, 150, 800],
      intensities: [0, _maxAmplitude, 0, _maxAmplitude, 0, _maxAmplitude],
    ),
  };

  /// Pulses are tuned by hand on real phones: the motor of a Samsung M32 does
  /// not spin up in 20 ms, though the system reports the pulse as played.
  /// iOS has a haptic engine and short vibrations of its own.
  @override
  Future<void> pulse(HapticLevel level) =>
      Platform.isIOS ? _iosPulse(level) : _vibratorPulse(level);

  Future<void> _vibratorPulse(HapticLevel level) => switch (level) {
    HapticLevel.tick => Vibration.vibrate(duration: 30),
    HapticLevel.press => Vibration.vibrate(duration: 40),
    HapticLevel.success => Vibration.vibrate(pattern: [0, 40, 60, 40]),
    HapticLevel.warning => Vibration.vibrate(pattern: [0, 70, 60, 70]),
  };

  Future<void> _iosPulse(HapticLevel level) => switch (level) {
    HapticLevel.tick => HapticFeedback.selectionClick(),
    HapticLevel.press || HapticLevel.success => HapticFeedback.mediumImpact(),
    HapticLevel.warning => HapticFeedback.heavyImpact(),
  };
}
