import 'package:wayback/core/error/exceptions.dart';
import 'package:wayback/core/error/failures.dart';

/// Maps a known data-layer exception. Return `null` to fall back to the
/// default mapping of `ResultHandler`.
typedef ExceptionMapper = Failure? Function(AppException exception);

/// Maps an error that is not an [AppException] (a bug or an unknown plugin
/// error). Return `null` to fall back to [UnexpectedFailure].
typedef UnexpectedErrorMapper =
    Failure? Function(Object error, StackTrace stackTrace);

/// Sees every caught error before it is mapped, e.g. to log or report it.
typedef ErrorObserver = void Function(Object error, StackTrace stackTrace);

/// Sees every failure a handled call or stream produces.
typedef FailureObserver = void Function(Failure failure);

/// Decides whether a failed call runs again; [attempt] starts at 1.
typedef RetryPredicate = bool Function(Failure failure, int attempt);

/// Everything `ResultHandler` lets a caller customise.
///
/// Usually one instance comes from DI with app-wide hooks (logging,
/// reporting); a repository takes it in its constructor and may adjust it
/// per call with [copyWith].
final class ResultHandlerOptions {
  const ResultHandlerOptions({
    this.onError,
    this.onFailure,
    this.mapException,
    this.mapUnexpected,
    this.timeout,
    this.maxAttempts = 1,
    this.retryIf,
    this.retryDelay = Duration.zero,
    this.cancelStreamOnFailure = false,
  }) : assert(maxAttempts >= 1, 'maxAttempts must be at least 1');

  /// Called with the raw error and stack trace of every caught error.
  final ErrorObserver? onError;

  /// Called with every failure that leaves the handler.
  final FailureObserver? onFailure;

  /// Overrides the exception mapping before `ResultHandler.mapException`.
  final ExceptionMapper? mapException;

  /// Overrides the mapping of errors that are not [AppException]s.
  final UnexpectedErrorMapper? mapUnexpected;

  /// Time limit for one attempt of `handle`; on expiry the attempt fails with
  /// [timeoutErrorCode] unless [mapUnexpected] says otherwise.
  final Duration? timeout;

  /// Upper bound of attempts for `handle`, the first one included.
  final int maxAttempts;

  /// Which failures are worth another attempt. Without it nothing is retried.
  final RetryPredicate? retryIf;

  /// Pause before every repeated attempt.
  final Duration retryDelay;

  /// Ends a handled stream after its first failure instead of going on.
  final bool cancelStreamOnFailure;

  ResultHandlerOptions copyWith({
    ErrorObserver? onError,
    FailureObserver? onFailure,
    ExceptionMapper? mapException,
    UnexpectedErrorMapper? mapUnexpected,
    Duration? timeout,
    int? maxAttempts,
    RetryPredicate? retryIf,
    Duration? retryDelay,
    bool? cancelStreamOnFailure,
  }) => ResultHandlerOptions(
    onError: onError ?? this.onError,
    onFailure: onFailure ?? this.onFailure,
    mapException: mapException ?? this.mapException,
    mapUnexpected: mapUnexpected ?? this.mapUnexpected,
    timeout: timeout ?? this.timeout,
    maxAttempts: maxAttempts ?? this.maxAttempts,
    retryIf: retryIf ?? this.retryIf,
    retryDelay: retryDelay ?? this.retryDelay,
    cancelStreamOnFailure: cancelStreamOnFailure ?? this.cancelStreamOnFailure,
  );
}
