import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/navigation/domain/repositories/vibration_repository.dart';

final class FakeVibrationRepository implements VibrationRepository {
  int calls = 0;

  @override
  Future<Result<void>> vibrate() async {
    calls++;
    return const Result.success(null);
  }
}
