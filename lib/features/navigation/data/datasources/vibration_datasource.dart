import 'package:wayback/core/utils/vibration/haptic_level.dart';
import 'package:wayback/core/utils/vibration/vibration_pattern.dart';

abstract interface class VibrationDatasource {
  Future<void> vibrate(VibrationPattern pattern);

  Future<void> pulse(HapticLevel level);
}
