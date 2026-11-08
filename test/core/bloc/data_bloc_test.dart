import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/bloc/data/data_bloc.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';

final class _Bloc extends DataBloc<int> {
  _Bloc(this.source);

  Stream<Result<int>> Function() source;
  int calls = 0;

  @override
  Stream<Result<int>> watch() {
    calls++;
    return source();
  }
}

const _failure = StorageFailure(code: 'read');

Future<List<DataState<int>>> _states(_Bloc bloc, void Function() act) async {
  final states = <DataState<int>>[];
  final sub = bloc.stream.listen(states.add);
  act();
  await pumpEventQueue();
  await sub.cancel();
  return states;
}

void main() {
  test('fetch: loading, then data', () async {
    final bloc = _Bloc(() => Stream.value(const Result.success(1)));
    addTearDown(bloc.close);

    expect(await _states(bloc, bloc.fetch), [
      const DataLoading<int>(),
      const DataSuccess(1),
    ]);
  });

  test('a changing source updates the shown data', () async {
    final source = StreamController<Result<int>>();
    final bloc = _Bloc(() => source.stream);
    addTearDown(bloc.close);

    final states = await _states(bloc, () {
      bloc.fetch();
      source
        ..add(const Result.success(1))
        ..add(const Result.success(2));
    });

    expect(states.last, const DataSuccess(2));
  });

  test('stop leaves the source and keeps the data for refresh', () async {
    final source = StreamController<Result<int>>.broadcast();
    final bloc = _Bloc(() => source.stream);
    addTearDown(bloc.close);

    bloc.fetch();
    await pumpEventQueue();
    source.add(const Result.success(1));
    await pumpEventQueue();

    bloc.stop();
    await pumpEventQueue();
    expect(source.hasListener, isFalse);
    expect(bloc.state, const DataSuccess(1));

    bloc.refresh();
    await pumpEventQueue();
    expect(source.hasListener, isTrue);
    expect(bloc.state.dataOrNull, 1);
  });

  test('refresh keeps the data visible and a failure keeps it too', () async {
    final bloc = _Bloc(() => Stream.value(const Result.success(1)));
    addTearDown(bloc.close);
    bloc.fetch();
    await pumpEventQueue();

    bloc.source = () => Stream.value(const Result.failure(_failure));
    final states = await _states(bloc, bloc.refresh);

    expect(states, [
      const DataLoading(previous: 1),
      const DataFailure<int>(_failure, previous: 1),
    ]);
    expect(bloc.state.dataOrNull, 1);
  });

  test('a new fetch cancels the previous subscription', () async {
    final first = StreamController<Result<int>>();
    final bloc = _Bloc(() => first.stream);
    addTearDown(bloc.close);
    bloc.fetch();
    await pumpEventQueue();

    bloc.source = () => Stream.value(const Result.success(2));
    bloc.fetch();
    await pumpEventQueue();
    first.add(const Result.success(1));
    await pumpEventQueue();

    expect(bloc.state, const DataSuccess(2));
    expect(first.hasListener, isFalse);
  });

  test('an exception in watch() becomes a failure', () async {
    final bloc = _Bloc(() => Stream.error(StateError('bug')));
    addTearDown(bloc.close);
    bloc.fetch();
    await pumpEventQueue();

    expect(
      bloc.state.mapOrNull(failure: (s) => s.failure),
      isA<UnexpectedFailure>(),
    );
  });

  test('map helpers pick the matching branch', () {
    const DataState<int> success = DataSuccess(5);
    const DataState<int> loading = DataLoading();

    expect(
      success.map(
        initial: (_) => 'i',
        loading: (_) => 'l',
        success: (s) => 's${s.data}',
        failure: (_) => 'f',
      ),
      's5',
    );
    expect(
      loading.mapOrElse(orElse: (_) => 'else', success: (_) => 's'),
      'else',
    );
    expect(loading.mapOrNull(success: (_) => 's'), isNull);
    expect(loading.mapOrNull(loading: (_) => 'l'), 'l');
  });
}
