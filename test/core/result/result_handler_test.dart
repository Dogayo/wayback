import 'dart:async' as async;

import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/result/result_handler.dart';

final class _Repository with ResultHandler {
  _Repository([this.resultOptions = const ResultHandlerOptions()]);

  @override
  final ResultHandlerOptions resultOptions;
}

final class _CustomRepository with ResultHandler {
  @override
  Failure mapException(AppException e) =>
      NotFoundFailure(code: 'custom_${e.code}');
}

final class _ThrowingStream extends Stream<int> {
  @override
  async.StreamSubscription<int> listen(
    void Function(int)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => throw StateError('listen');
}

Future<List<Result<int>>> _collect(Stream<Result<int>> stream) async {
  final results = <Result<int>>[];
  await stream.forEach(results.add);
  return results;
}

void main() {
  group('handle', () {
    test('a value becomes a success', () async {
      expect(await _Repository().handle(() async => 42), const Success(42));
      expect(await _Repository().handle(() => 7), const Success(7));
    });

    test('each exception becomes the failure of the same kind', () async {
      final cases = <AppException, Failure>{
        const StorageException(code: 'a', description: 'd'):
            const StorageFailure(code: 'a', description: 'd'),
        const PermissionException(code: 'b'): const PermissionFailure(
          code: 'b',
        ),
        const SensorException(code: 'c'): const SensorFailure(code: 'c'),
        const NotFoundException(code: 'd'): const NotFoundFailure(code: 'd'),
        const NetworkException(code: 'e'): const NetworkFailure(code: 'e'),
        const TimeoutException(code: 'f'): const TimeoutFailure(code: 'f'),
        const ServerException(code: 'g'): const ServerFailure(code: 'g'),
      };

      for (final MapEntry(key: exception, value: failure) in cases.entries) {
        final result = await _Repository().handle<int>(
          () async => throw exception,
        );
        expect(result.failureOrNull, failure);
      }
    });

    test('a bug never escapes as an exception', () async {
      final async = await _Repository().handle<int>(
        () async => throw StateError('bug'),
      );
      final sync = await _Repository().handle<int>(
        () => throw ArgumentError('sync bug'),
      );

      for (final result in [async, sync]) {
        expect(result.failureOrNull, isA<UnexpectedFailure>());
        expect(result.failureOrNull!.code, unexpectedErrorCode);
      }
    });

    test('timeout fails the attempt with the timeout code', () async {
      final result = await _Repository(
        const ResultHandlerOptions(timeout: Duration(milliseconds: 10)),
      ).handle(() => Future.delayed(const Duration(seconds: 1), () => 1));

      expect(result.failureOrNull?.code, timeoutErrorCode);
    });

    test('observers see the raw error and the produced failure', () async {
      final errors = <Object>[];
      final failures = <Failure>[];
      final repository = _Repository(
        ResultHandlerOptions(
          onError: (error, _) => errors.add(error),
          onFailure: failures.add,
        ),
      );

      await repository.handle<int>(
        () async => throw const SensorException(code: 'lost'),
      );

      expect(errors.single, isA<SensorException>());
      expect(failures, [const SensorFailure(code: 'lost')]);
    });

    test('external mappers come first, null falls back', () async {
      final repository = _Repository(
        ResultHandlerOptions(
          mapException: (e) =>
              e.code == 'special' ? NotFoundFailure(code: e.code) : null,
          mapUnexpected: (error, _) =>
              const StorageFailure(code: 'from_outside'),
        ),
      );

      expect(
        (await repository.handle<int>(
          () async => throw const SensorException(code: 'special'),
        )).failureOrNull,
        const NotFoundFailure(code: 'special'),
      );
      expect(
        (await repository.handle<int>(
          () async => throw const SensorException(code: 'plain'),
        )).failureOrNull,
        const SensorFailure(code: 'plain'),
      );
      expect(
        (await repository.handle<int>(
          () async => throw StateError('x'),
        )).failureOrNull,
        const StorageFailure(code: 'from_outside'),
      );
    });

    test('a repository can override the default mapping', () async {
      final result = await _CustomRepository().handle<int>(
        () async => throw const SensorException(code: 'x'),
      );

      expect(result.failureOrNull, const NotFoundFailure(code: 'custom_x'));
    });

    test('retries while retryIf agrees and attempts remain', () async {
      var calls = 0;
      final attempts = <int>[];
      final result =
          await _Repository(
            ResultHandlerOptions(
              maxAttempts: 3,
              retryIf: (_, attempt) {
                attempts.add(attempt);
                return true;
              },
            ),
          ).handle(() async {
            calls++;
            if (calls < 3) throw const SensorException(code: 'flaky');
            return calls;
          });

      expect(result, const Success(3));
      expect(attempts, [1, 2]);
    });

    test('stops at maxAttempts and without retryIf does not retry', () async {
      var calls = 0;
      Future<int> failing() async {
        calls++;
        throw const SensorException(code: 'down');
      }

      await _Repository(
        ResultHandlerOptions(maxAttempts: 2, retryIf: (_, _) => true),
      ).handle(failing);
      expect(calls, 2);

      calls = 0;
      await _Repository(
        const ResultHandlerOptions(maxAttempts: 5),
      ).handle(failing);
      expect(calls, 1);
    });

    test('a throwing mapper or hook does not break handling', () async {
      final errors = <Object>[];
      final repository = _Repository(
        ResultHandlerOptions(
          onError: (e, _) => errors.add(e),
          onFailure: (_) => throw StateError('broken observer'),
          mapException: (_) => throw StateError('broken mapper'),
          retryIf: (_, _) => throw StateError('broken predicate'),
          maxAttempts: 3,
        ),
      );

      final result = await repository.handle<int>(
        () async => throw const SensorException(code: 'x'),
      );

      expect(result.failureOrNull, isA<UnexpectedFailure>());
      expect(errors, hasLength(2));
      expect(errors.last, isA<StateError>());
    });

    test('options can be replaced for one call', () async {
      final result = await _Repository().handle(
        () => Future.delayed(const Duration(seconds: 1), () => 1),
        options: const ResultHandlerOptions(
          timeout: Duration(milliseconds: 10),
        ),
      );

      expect(result.failureOrNull?.code, timeoutErrorCode);
    });
  });

  group('handleStream', () {
    test('turns every error into a failure and goes on', () async {
      final source = async.StreamController<int>();
      final results = _collect(_Repository().handleStream(source.stream));

      source
        ..add(1)
        ..addError(const SensorException(code: 'lost'))
        ..addError(StateError('bug'))
        ..add(2);
      await source.close();

      final list = await results;
      expect(list[0], const Success(1));
      expect(list[1], const Failed<int>(SensorFailure(code: 'lost')));
      expect(list[2].failureOrNull, isA<UnexpectedFailure>());
      expect(list[3], const Success(2));
    });

    test('can end after the first failure', () async {
      final source = async.StreamController<int>();
      final results = _collect(
        _Repository(
          const ResultHandlerOptions(cancelStreamOnFailure: true),
        ).handleStream(source.stream),
      );

      source
        ..add(1)
        ..addError(const SensorException(code: 'lost'))
        ..add(2);

      final list = await results;
      expect(list, [
        const Success(1),
        const Failed<int>(SensorFailure(code: 'lost')),
      ]);
      await source.close();
    });

    test('a stream that throws on listen yields a failure', () async {
      final broken = _ThrowingStream();

      final list = await _collect(_Repository().handleStream(broken));

      expect(list.single.failureOrNull, isA<UnexpectedFailure>());
    });

    test('observers see stream failures', () async {
      final failures = <Failure>[];
      final source = async.StreamController<int>();
      final results = _collect(
        _Repository(
          ResultHandlerOptions(onFailure: failures.add),
        ).handleStream(source.stream),
      );

      source.addError(const PermissionException(code: 'denied'));
      await source.close();
      await results;

      expect(failures, [const PermissionFailure(code: 'denied')]);
    });
  });
}
