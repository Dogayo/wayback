import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/vibration/haptic_level.dart';
import 'package:wayback/core/utils/vibration/vibration_pattern.dart';
import 'package:wayback/features/navigation/data/datasources/vibration_datasource.dart';
import 'package:wayback/features/navigation/data/repositories/vibration_repository_impl.dart';

final class _Datasource implements VibrationDatasource {
  _Datasource({this.fails = false});

  final bool fails;
  final patterns = <VibrationPattern>[];
  final pulses = <HapticLevel>[];

  @override
  Future<void> vibrate(VibrationPattern pattern) async {
    patterns.add(pattern);
    if (fails) throw StateError('no vibrator');
  }

  @override
  Future<void> pulse(HapticLevel level) async {
    pulses.add(level);
    if (fails) throw StateError('no vibrator');
  }
}

void main() {
  test('pulses through the datasource', () async {
    final datasource = _Datasource();
    final result = await VibrationRepositoryImpl(
      datasource,
    ).pulse(HapticLevel.press);

    expect(result, isA<Success<void>>());
    expect(datasource.pulses, [HapticLevel.press]);
  });

  test('a phone that cannot pulse is a result, not an exception', () async {
    final result = await VibrationRepositoryImpl(
      _Datasource(fails: true),
    ).pulse(HapticLevel.tick);

    expect(result, isA<Failed<void>>());
  });

  test('vibrates through the datasource', () async {
    final datasource = _Datasource();
    final result = await VibrationRepositoryImpl(
      datasource,
    ).vibrate(VibrationPattern.twice);

    expect(result, isA<Success<void>>());
    expect(datasource.patterns, [VibrationPattern.twice]);
  });

  test('a failed vibrator is a failure, not an exception', () async {
    final result = await VibrationRepositoryImpl(
      _Datasource(fails: true),
    ).vibrate(VibrationPattern.standard);

    expect(result, isA<Failed<void>>());
  });
}
