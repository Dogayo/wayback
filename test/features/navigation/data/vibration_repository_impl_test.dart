import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/utils/vibration/vibration_pattern.dart';
import 'package:wayback/features/navigation/data/datasources/vibration_datasource.dart';
import 'package:wayback/features/navigation/data/repositories/vibration_repository_impl.dart';

final class _Datasource implements VibrationDatasource {
  _Datasource({this.fails = false});

  final bool fails;
  final patterns = <VibrationPattern>[];

  @override
  Future<void> vibrate(VibrationPattern pattern) async {
    patterns.add(pattern);
    if (fails) throw StateError('no vibrator');
  }
}

void main() {
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
