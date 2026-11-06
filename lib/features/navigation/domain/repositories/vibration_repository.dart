import 'package:wayback/core/result/result.dart';

/// Every method returns a [Result]; none of them throws.
abstract interface class VibrationRepository {
  /// One vibration the user feels in a hand or a pocket. It does not depend
  /// on the system's touch feedback settings.
  Future<Result<void>> vibrate();
}
