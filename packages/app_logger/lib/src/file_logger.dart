import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_logger/src/app_logger.dart';
import 'package:app_logger/src/log_record.dart';

/// Appends JSON lines to `wayback-<time>.jsonl` files in [directory].
///
/// Records are buffered and written every [flushInterval]; warnings and
/// errors are written at once, so a crash keeps what led to it. A file over
/// [maxFileBytes] rolls over; files older than [maxAge] or beyond
/// [maxTotalBytes] are deleted, oldest first.
final class FileLogger implements AppLogger {
  FileLogger({
    required this.directory,
    this.maxFileBytes = 1024 * 1024,
    this.maxTotalBytes = 5 * 1024 * 1024,
    this.maxAge = const Duration(days: 7),
    this.flushInterval = const Duration(seconds: 2),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const _prefix = 'wayback-';
  static const _extension = '.jsonl';
  static const exportName = 'wayback-log.jsonl';

  final Directory directory;
  final int maxFileBytes;
  final int maxTotalBytes;
  final Duration maxAge;
  final Duration flushInterval;
  final DateTime Function() _now;

  final _buffer = <String>[];
  Timer? _timer;
  File? _current;

  /// Writes run one at a time, in order.
  Future<void> _writes = Future.value();

  @override
  void log(
    LogLevel level,
    String tag,
    String message, {
    Map<String, Object?> fields = const {},
    Map<String, Object?> private = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    try {
      _buffer.add(
        jsonEncode(
          LogRecord(
            time: _now(),
            level: level,
            tag: tag,
            message: message,
            fields: fields,
            private: private,
            error: error,
            stackTrace: stackTrace,
          ).toJson(),
          toEncodable: (value) => '$value',
        ),
      );
    } on Object {
      return; // E.g. NaN in a field: lose the line, not the app.
    }
    if (level.index >= LogLevel.warning.index) {
      unawaited(flush());
    } else {
      _timer ??= Timer(flushInterval, () => unawaited(flush()));
    }
  }

  @override
  Future<void> flush() {
    _timer?.cancel();
    _timer = null;
    return _writes = _writes.then((_) => _drain());
  }

  Future<void> _drain() async {
    if (_buffer.isEmpty) return;
    final lines = _buffer.join('\n');
    _buffer.clear();
    try {
      await directory.create(recursive: true);
      final file = _current ??= _newFile();
      await file.writeAsString('$lines\n', mode: FileMode.append, flush: true);
      if (await file.length() >= maxFileBytes) {
        _current = null;
        await _prune();
      }
    } on Object {
      _current = null; // A full disk or a removed directory: try a new file.
    }
  }

  File _newFile() {
    final stamp = _now().toUtc().toIso8601String().replaceAll(':', '-');
    return File('${directory.path}/$_prefix$stamp$_extension');
  }

  /// Log files, oldest first: names sort by time.
  Future<List<File>> _files() async {
    if (!directory.existsSync()) return const [];
    final files = await directory
        .list()
        .where(
          (entity) =>
              entity is File &&
              entity.uri.pathSegments.last.startsWith(_prefix) &&
              entity.path.endsWith(_extension),
        )
        .cast<File>()
        .toList();
    return files..sort((a, b) => a.path.compareTo(b.path));
  }

  /// Deletes what is over the limits; also run it on start.
  Future<void> prune() => _writes = _writes.then((_) => _prune());

  Future<void> _prune() async {
    try {
      final oldest = _now().subtract(maxAge);
      final kept = <File>[];
      for (final file in await _files()) {
        if (file.lastModifiedSync().isBefore(oldest)) {
          await file.delete();
        } else {
          kept.add(file);
        }
      }
      var total = 0;
      for (final file in kept) {
        total += await file.length();
      }
      for (final file in kept) {
        if (total <= maxTotalBytes || file.path == _current?.path) continue;
        total -= await file.length();
        await file.delete();
      }
    } on Object {
      return; // The next rollover tries again.
    }
  }

  @override
  Future<File?> exportShareable() async {
    await flush();
    try {
      final files = await _files();
      if (files.isEmpty) return null;
      final export = Directory('${directory.path}/export');
      await export.create(recursive: true);
      final out = File('${export.path}/$exportName').openWrite();
      for (final file in files) {
        for (final line in await file.readAsLines()) {
          if (_withoutPrivate(line) case final clean?) out.writeln(clean);
        }
      }
      await out.close();
      return File('${export.path}/$exportName');
    } on Object {
      return null;
    }
  }

  /// `null` for a line cut short by a crash: it can't be cleaned, so it
  /// doesn't leave the device.
  static String? _withoutPrivate(String line) {
    try {
      final record = jsonDecode(line) as Map<String, dynamic>
        ..remove(LogRecord.privateKey);
      return jsonEncode(record);
    } on Object {
      return null;
    }
  }
}
