import 'dart:async' as async;

import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/core/result/result_handler_options.dart';

export 'package:wayback/core/result/result_handler_options.dart';

/// One way for every repository to turn data-layer calls into [Result]s.
///
/// Nothing thrown by a handled call or stream leaves the handler as an
/// exception — not an [AppException], not a bug, not an error inside a hook
/// or a mapper. Everything becomes a [Failure] (architecture.md §4.3).
///
/// Behaviour is set by [resultOptions], usually injected through the
/// repository constructor, and can be replaced for a single call:
///
/// ```dart
/// final class PointsRepositoryImpl with ResultHandler
///     implements PointsRepository {
///   PointsRepositoryImpl(this._local, {this.resultOptions = const ResultHandlerOptions()});
///
///   @override
///   final ResultHandlerOptions resultOptions;
///
///   @override
///   Future<Result<List<SavedPoint>>> getAll() =>
///       handle(() async => (await _local.readAll()).map(toEntity).toList());
/// }
/// ```
mixin ResultHandler {
  /// Options for every handled call; override to inject them.
  ResultHandlerOptions get resultOptions => const ResultHandlerOptions();

  Future<Result<T>> handle<T>(
    async.FutureOr<T> Function() call, {
    ResultHandlerOptions? options,
  }) async {
    final o = options ?? resultOptions;
    for (var attempt = 1; ; attempt++) {
      final Failure failure;
      try {
        final timeout = o.timeout;
        final value = timeout == null
            ? await call()
            : await Future.sync(call).timeout(timeout);
        return Result.success(value);
      } on Object catch (error, stackTrace) {
        failure = _toFailure(error, stackTrace, o);
      }
      if (attempt < o.maxAttempts && _shouldRetry(o, failure, attempt)) {
        await Future<void>.delayed(o.retryDelay);
        continue;
      }
      _notify(() => o.onFailure?.call(failure));
      return Result.failure(failure);
    }
  }

  /// Every event becomes a [Result]; any error in the stream becomes a
  /// failure. The stream goes on after a failure unless
  /// [ResultHandlerOptions.cancelStreamOnFailure] is set.
  Stream<Result<T>> handleStream<T>(
    Stream<T> stream, {
    ResultHandlerOptions? options,
  }) {
    final o = options ?? resultOptions;
    late final async.StreamController<Result<T>> controller;
    async.StreamSubscription<T>? subscription;

    void fail(Object error, StackTrace stackTrace) {
      final failure = _toFailure(error, stackTrace, o);
      _notify(() => o.onFailure?.call(failure));
      controller.add(Result.failure(failure));
      if (o.cancelStreamOnFailure) {
        async.unawaited(subscription?.cancel());
        async.unawaited(controller.close());
      }
    }

    controller = async.StreamController<Result<T>>(
      onListen: () {
        try {
          subscription = stream.listen(
            (value) => controller.add(Result.success(value)),
            onError: fail,
            onDone: controller.close,
          );
        } on Object catch (error, stackTrace) {
          fail(error, stackTrace);
          async.unawaited(controller.close());
        }
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  /// Default mapping of a data-layer exception: keeps the code and
  /// description, picks the failure of the same kind. Applied when
  /// [ResultHandlerOptions.mapException] is absent or returns `null`;
  /// override for a repository-wide rule.
  Failure mapException(AppException e) => switch (e) {
    StorageException() => StorageFailure(
      code: e.code,
      description: e.description,
      cause: e.cause,
      stackTrace: e.stackTrace,
    ),
    PermissionException() => PermissionFailure(
      code: e.code,
      description: e.description,
      cause: e.cause,
      stackTrace: e.stackTrace,
    ),
    SensorException() => SensorFailure(
      code: e.code,
      description: e.description,
      cause: e.cause,
      stackTrace: e.stackTrace,
    ),
    NotFoundException() => NotFoundFailure(
      code: e.code,
      description: e.description,
      cause: e.cause,
      stackTrace: e.stackTrace,
    ),
    NetworkException() => NetworkFailure(
      code: e.code,
      description: e.description,
      cause: e.cause,
      stackTrace: e.stackTrace,
    ),
    TimeoutException() => TimeoutFailure(
      code: e.code,
      description: e.description,
      cause: e.cause,
      stackTrace: e.stackTrace,
    ),
    ServerException() => ServerFailure(
      code: e.code,
      description: e.description,
      cause: e.cause,
      stackTrace: e.stackTrace,
    ),
  };

  /// Default mapping of an error that is not an [AppException]. Applied when
  /// [ResultHandlerOptions.mapUnexpected] is absent or returns `null`.
  Failure mapUnexpected(Object error, StackTrace stackTrace) =>
      UnexpectedFailure(
        code: error is async.TimeoutException
            ? timeoutErrorCode
            : unexpectedErrorCode,
        description: '$error',
        cause: error,
        stackTrace: stackTrace,
      );

  Failure _toFailure(
    Object error,
    StackTrace stackTrace,
    ResultHandlerOptions o,
  ) {
    _notify(() => o.onError?.call(error, stackTrace));
    try {
      return switch (error) {
        AppException() => o.mapException?.call(error) ?? mapException(error),
        _ =>
          o.mapUnexpected?.call(error, stackTrace) ??
              mapUnexpected(error, stackTrace),
      };
    } on Object catch (mapperError, mapperStackTrace) {
      // A broken mapper must not turn the failure back into an exception.
      _notify(() => o.onError?.call(mapperError, mapperStackTrace));
      return UnexpectedFailure(
        description: 'Mapping $error failed: $mapperError',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Runs an observer; one that throws is ignored, it must not break handling.
  static void _notify(void Function() observer) {
    try {
      observer();
    } on Object {
      // Ignored on purpose: observers are best effort.
    }
  }

  /// A predicate that throws counts as "do not retry".
  static bool _shouldRetry(
    ResultHandlerOptions o,
    Failure failure,
    int attempt,
  ) {
    try {
      return o.retryIf?.call(failure, attempt) ?? false;
    } on Object {
      return false;
    }
  }
}
