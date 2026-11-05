/// Errors of `domain` and `view`. Repositories return them inside a `Result`
/// instead of throwing (architecture.md §4).
///
/// [code] is the same stable key as on the exception it came from; the view
/// shows the `error_<code>` translation. [description] is for logs only.
///
/// Two failures are equal when their type, [code] and [description] match,
/// so they compare cleanly inside Bloc states.
sealed class Failure {
  const Failure({
    required this.code,
    this.description,
    this.cause,
    this.stackTrace,
  });

  final String code;
  final String? description;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          other.runtimeType == runtimeType &&
          other.code == code &&
          other.description == description;

  @override
  int get hashCode => Object.hash(runtimeType, code, description);

  @override
  String toString() =>
      ['$runtimeType($code)', if (description != null) description].join(': ');
}

/// An error that is not an `AppException`: a bug or an unknown plugin error
/// caught by `ResultHandler`, so it still reaches the view as a [Failure]
/// instead of an exception. Shown with the generic text.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.code = unexpectedErrorCode,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

/// Code of [UnexpectedFailure] for an error that is neither a timeout nor
/// otherwise classified.
const unexpectedErrorCode = 'unexpected';

/// Code of [UnexpectedFailure] when a call ran out of time.
const timeoutErrorCode = 'timeout';

sealed class LocalFailure extends Failure {
  const LocalFailure({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

final class StorageFailure extends LocalFailure {
  const StorageFailure({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

final class PermissionFailure extends LocalFailure {
  const PermissionFailure({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

final class SensorFailure extends LocalFailure {
  const SensorFailure({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

final class NotFoundFailure extends LocalFailure {
  const NotFoundFailure({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

/// Not used in MVP: the app is offline.
sealed class RemoteFailure extends Failure {
  const RemoteFailure({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

final class NetworkFailure extends RemoteFailure {
  const NetworkFailure({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

final class TimeoutFailure extends RemoteFailure {
  const TimeoutFailure({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

final class ServerFailure extends RemoteFailure {
  const ServerFailure({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}
