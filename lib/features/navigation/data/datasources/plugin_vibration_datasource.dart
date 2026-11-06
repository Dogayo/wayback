import 'package:vibration/vibration.dart';
import 'package:wayback/features/navigation/data/datasources/vibration_datasource.dart';

/// The vibrator itself, not `HapticFeedback`: touch feedback stayed silent
/// on a Samsung M32 in the field check, and it is meant for taps anyway.
final class PluginVibrationDatasource implements VibrationDatasource {
  const PluginVibrationDatasource();

  static const _durationMilliseconds = 400;

  @override
  Future<void> vibrate() => Vibration.vibrate(duration: _durationMilliseconds);
}
