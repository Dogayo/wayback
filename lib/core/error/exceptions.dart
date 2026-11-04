/// Errors of the `data` layer. Datasources throw them; repositories catch
/// them and return a `Failure` instead (architecture.md §4).
///
/// [code] is a stable `snake_case` key with an area prefix, e.g.
/// `points_storage_write_failed`. It doubles as the l10n key `error_<code>`.
/// [description] is for logs only and is never shown to the user.
sealed class AppException implements Exception {
  const AppException({
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
  String toString() => [
    '$runtimeType($code)',
    if (description != null) description,
    if (cause != null) 'cause: $cause',
  ].join(': ');
}

sealed class LocalException extends AppException {
  const LocalException({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

final class StorageException extends LocalException {
  const StorageException({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

final class PermissionException extends LocalException {
  const PermissionException({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

final class SensorException extends LocalException {
  const SensorException({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

final class NotFoundException extends LocalException {
  const NotFoundException({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

/// Not used in MVP: the app is offline. Declared so post-MVP network
/// features do not break the contract.
sealed class RemoteException extends AppException {
  const RemoteException({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

final class NetworkException extends RemoteException {
  const NetworkException({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

/// Shadows `dart:async`'s `TimeoutException`; hide one of them on import
/// when both are needed.
final class TimeoutException extends RemoteException {
  const TimeoutException({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}

final class ServerException extends RemoteException {
  const ServerException({
    required super.code,
    super.description,
    super.cause,
    super.stackTrace,
  });
}
