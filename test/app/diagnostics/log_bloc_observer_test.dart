import 'dart:io';

import 'package:app_logger/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/app/diagnostics/log_bloc_observer.dart';

final class _CounterCubitLikeBloc extends Bloc<Object, Object> {
  _CounterCubitLikeBloc() : super('text') {
    on<Object>((event, emit) => emit(event));
  }
}

void main() {
  late Directory directory;
  late FileLogger logger;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('observer_test');
    logger = FileLogger(directory: directory);
    Bloc.observer = LogBlocObserver(logger);
    addTearDown(() => Bloc.observer = const _Silent());
  });

  tearDown(() => directory.delete(recursive: true));

  test('logs a change of state kind, not new data of the same kind', () async {
    final bloc = _CounterCubitLikeBloc();
    addTearDown(bloc.close);

    bloc.add('secret name');
    await pumpEventQueue();
    bloc.add(1);
    await pumpEventQueue();
    await logger.flush();

    final files = (await directory.list().toList()).whereType<File>();
    final log = await files.single.readAsString();
    expect('"msg":"_CounterCubitLikeBloc"'.allMatches(log), hasLength(1));
    expect(log, contains('"to":"int"'));
    expect(log, isNot(contains('secret name')));
  });
}

final class _Silent extends BlocObserver {
  const _Silent();
}
