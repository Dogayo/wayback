import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/vibration/haptic_level.dart';
import 'package:wayback/core/utils/vibration/vibration_pattern.dart';

/// Every method returns a [Result]; none of them throws.
abstract interface class VibrationRepository {
  /// One [pattern] the user feels in a hand or a pocket. It does not depend
  /// on the system's touch feedback settings.
  Future<Result<void>> vibrate(VibrationPattern pattern);

  /// A short answer to the user's action; it does not depend on the system's
  /// touch feedback settings either.
  Future<Result<void>> pulse(HapticLevel level);
}
