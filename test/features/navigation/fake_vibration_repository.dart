import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/vibration/vibration_pattern.dart';
import 'package:wayback/features/navigation/domain/repositories/vibration_repository.dart';

final class FakeVibrationRepository implements VibrationRepository {
  final patterns = <VibrationPattern>[];

  int get calls => patterns.length;

  @override
  Future<Result<void>> vibrate(VibrationPattern pattern) async {
    patterns.add(pattern);
    return const Result.success(null);
  }
}
