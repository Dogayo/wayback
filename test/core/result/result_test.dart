import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';

void main() {
  const failure = StorageFailure(code: 'points_storage_read_failed');

  group('success', () {
    const result = Result<int>.success(2);

    test('exposes the value', () {
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 2);
      expect(result.failureOrNull, isNull);
    });

    test('fold takes the success branch', () {
      expect(
        result.fold(onSuccess: (v) => 'v$v', onFailure: (f) => f.code),
        'v2',
      );
    });

    test('map transforms the value', () {
      expect(result.map((v) => v * 10), const Result<int>.success(20));
    });
  });

  group('failure', () {
    const result = Result<int>.failure(failure);

    test('exposes the failure', () {
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, failure);
    });

    test('fold takes the failure branch', () {
      expect(
        result.fold(onSuccess: (v) => 'v$v', onFailure: (f) => f.code),
        'points_storage_read_failed',
      );
    });

    test('map passes the failure through', () {
      final mapped = result.map((v) => '$v');

      expect(mapped, isA<Failed<String>>());
      expect(mapped.failureOrNull, failure);
    });
  });

  test('switch is exhaustive over both variants', () {
    String describe(Result<int> r) => switch (r) {
      Success(:final value) => 'ok $value',
      Failed(:final failure) => 'error ${failure.code}',
    };

    expect(describe(const Success(1)), 'ok 1');
    expect(describe(const Failed(failure)), 'error points_storage_read_failed');
  });

  test('equality compares the content', () {
    expect(const Success(1), const Success(1));
    expect(const Success(1), isNot(const Success(2)));
    expect(const Failed<int>(failure), const Failed<int>(failure));
  });
}
