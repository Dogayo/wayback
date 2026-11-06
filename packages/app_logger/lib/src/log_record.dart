enum LogLevel { debug, info, warning, error }

/// One line of the log.
final class LogRecord {
  const LogRecord({
    required this.time,
    required this.level,
    required this.tag,
    required this.message,
    this.fields = const {},
    this.private = const {},
    this.error,
    this.stackTrace,
  });

  /// JSON key of [private]; export removes it from every line.
  static const privateKey = 'p';

  final DateTime time;
  final LogLevel level;

  /// Area of the app, e.g. `navigation`.
  final String tag;
  final String message;
  final Map<String, Object?> fields;

  /// Stays in the local files and never leaves the device, e.g. coordinates.
  final Map<String, Object?> private;
  final Object? error;
  final StackTrace? stackTrace;

  Map<String, Object?> toJson() => {
    't': time.toUtc().toIso8601String(),
    'l': level.name,
    'tag': tag,
    'msg': message,
    if (fields.isNotEmpty) 'f': fields,
    if (private.isNotEmpty) privateKey: private,
    if (error != null) 'err': '$error',
    if (stackTrace != null) 'stack': '$stackTrace',
  };
}
