import 'dart:io';

import 'package:app_logger/src/log_record.dart';

/// Writes the diagnostic log. No method throws: a logging failure must never
/// break the app.
abstract interface class AppLogger {
  void log(
    LogLevel level,
    String tag,
    String message, {
    Map<String, Object?> fields,
    Map<String, Object?> private,
    Object? error,
    StackTrace? stackTrace,
  });

  /// Writes everything buffered, e.g. before the app goes to the background.
  Future<void> flush();

  /// A copy of the whole log without private fields, or `null` if there is
  /// nothing to share or it could not be written.
  Future<File?> exportShareable();
}

extension AppLoggerLevels on AppLogger {
  void debug(
    String tag,
    String message, {
    Map<String, Object?> fields = const {},
    Map<String, Object?> private = const {},
  }) => log(LogLevel.debug, tag, message, fields: fields, private: private);

  void info(
    String tag,
    String message, {
    Map<String, Object?> fields = const {},
    Map<String, Object?> private = const {},
  }) => log(LogLevel.info, tag, message, fields: fields, private: private);

  void warning(
    String tag,
    String message, {
    Map<String, Object?> fields = const {},
  }) => log(LogLevel.warning, tag, message, fields: fields);

  void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const {},
  }) => log(
    LogLevel.error,
    tag,
    message,
    fields: fields,
    error: error,
    stackTrace: stackTrace,
  );
}

/// Logs nothing: for tests, and for a device where no log directory exists.
final class NoopLogger implements AppLogger {
  const NoopLogger();

  @override
  void log(
    LogLevel level,
    String tag,
    String message, {
    Map<String, Object?> fields = const {},
    Map<String, Object?> private = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  Future<void> flush() async {}

  @override
  Future<File?> exportShareable() async => null;
}
