import 'dart:convert';
import 'dart:io';

import 'package:app_logger/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('app_logger_test');
  });

  tearDown(() => directory.delete(recursive: true));

  Future<List<File>> logFiles() async =>
      (await directory.list().toList()).whereType<File>().toList();

  Future<List<Map<String, dynamic>>> records() async => [
    for (final file in await logFiles())
      for (final line in await file.readAsLines())
        jsonDecode(line) as Map<String, dynamic>,
  ];

  test('a record becomes one JSON line', () async {
    final logger = FileLogger(directory: directory)
      ..info('navigation', 'tick', fields: {'accuracy': 8});
    await logger.flush();

    final record = (await records()).single;
    expect(record['l'], 'info');
    expect(record['tag'], 'navigation');
    expect(record['msg'], 'tick');
    expect(record['f'], {'accuracy': 8});
    expect(DateTime.parse(record['t'] as String).isUtc, isTrue);
  });

  test('an error is written without waiting for the timer', () async {
    final logger = FileLogger(
      directory: directory,
      flushInterval: const Duration(hours: 1),
    )..error('app', 'crash', error: StateError('boom'));
    await logger.flush();

    final record = (await records()).single;
    expect(record['err'], contains('boom'));
    expect(record['l'], 'error');
  });

  test('buffered records reach the disk after the interval', () async {
    FileLogger(
      directory: directory,
      flushInterval: const Duration(milliseconds: 10),
    ).info('app', 'started');

    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(await records(), hasLength(1));
  });

  test('a value JSON cannot hold does not throw', () async {
    final logger = FileLogger(directory: directory)
      ..info('app', 'bad', fields: {'value': double.nan})
      ..info('app', 'object', fields: {'value': Object()})
      ..info('app', 'good');
    await logger.flush();

    expect((await records()).last['msg'], 'good');
  });

  test('a file over the limit rolls over', () async {
    var clock = DateTime.utc(2026, 11, 6);
    final logger = FileLogger(
      directory: directory,
      maxFileBytes: 50,
      now: () => clock = clock.add(const Duration(seconds: 1)),
    )..info('app', 'first record, long enough to fill the file');
    await logger.flush();
    logger.info('app', 'second');
    await logger.flush();

    expect(await logFiles(), hasLength(2));
  });

  test('the oldest files go when the total is over the limit', () async {
    var clock = DateTime.utc(2026, 11, 6);
    final logger = FileLogger(
      directory: directory,
      maxFileBytes: 50,
      maxTotalBytes: 200,
      maxAge: const Duration(days: 100000),
      now: () => clock = clock.add(const Duration(seconds: 1)),
    );
    for (var i = 0; i < 10; i++) {
      logger.info('app', 'record $i, long enough to fill one whole file');
      await logger.flush();
    }

    final messages = [for (final r in await records()) r['msg'] as String];
    expect(messages, isNot(contains(startsWith('record 0'))));
    expect(messages, contains(startsWith('record 9')));
  });

  test('files older than the limit are deleted on prune', () async {
    final old = File('${directory.path}/wayback-2026-01-01.jsonl')
      ..writeAsStringSync('{}\n')
      ..setLastModifiedSync(DateTime.utc(2026));
    final foreign = File('${directory.path}/other.txt')
      ..writeAsStringSync('keep');

    await FileLogger(
      directory: directory,
      now: () => DateTime.utc(2026, 11, 6),
    ).prune();

    expect(old.existsSync(), isFalse);
    expect(foreign.existsSync(), isTrue);
  });

  test('export removes private fields and keeps the rest', () async {
    final logger = FileLogger(directory: directory)
      ..info(
        'navigation',
        'tick',
        fields: {'accuracy': 8},
        private: {'lat': 55.75, 'lon': 37.61},
      );

    final file = (await logger.exportShareable())!;

    final text = await file.readAsString();
    expect(text, isNot(contains('55.75')));
    expect(text, isNot(contains('"p"')));
    expect(text, contains('"accuracy":8'));
    final local = await logFiles();
    expect(await local.single.readAsString(), contains('55.75'));
  });

  test('a line cut by a crash does not leave the device', () async {
    File(
      '${directory.path}/wayback-2026-11-06.jsonl',
    ).writeAsStringSync('{"t":"x","p":{"lat":55.75\n');
    final logger = FileLogger(directory: directory)..info('app', 'next');

    final text = await (await logger.exportShareable())!.readAsString();

    expect(text, isNot(contains('55.75')));
    expect(text, contains('next'));
  });

  test('nothing to export is null', () async {
    expect(await FileLogger(directory: directory).exportShareable(), isNull);
  });

  test('an unwritable directory does not throw', () async {
    final blocker = File('${directory.path}/file')..writeAsStringSync('x');
    final logger = FileLogger(directory: Directory('${blocker.path}/logs'))
      ..error('app', 'lost');

    await logger.flush();
    expect(await logger.exportShareable(), isNull);
  });

  test('NoopLogger does nothing', () async {
    const logger = NoopLogger();
    logger.info('app', 'ignored');
    await logger.flush();
    expect(await logger.exportShareable(), isNull);
  });
}
