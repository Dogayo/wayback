import 'package:vibration/vibration.dart';
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
}
