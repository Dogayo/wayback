import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';

final class _Double extends ActionBloc<int, int> {
  int calls = 0;
  Completer<void>? gate;
  Error? throwThis;

  @override
  Future<Result<int>> perform(int params) async {
    calls++;
    await gate?.future;
    if (throwThis case final error?) throw error;
    return params < 0
        ? const Result.failure(StorageFailure(code: 'negative'))
        : Result.success(params * 2);
  }
}

void main() {
  late _Double bloc;

  setUp(() => bloc = _Double());
  tearDown(() => bloc.close());

  test('run: in progress, then the result', () async {
    final states = <ActionState<int>>[];
    final sub = bloc.stream.listen(states.add);
    bloc.run(21);
    await pumpEventQueue();
    await sub.cancel();

    expect(states, [const ActionInProgress<int>(), const ActionSuccess(42)]);
  });

  test('a failure and a reset', () async {
    bloc.run(-1);
    await pumpEventQueue();
    expect(
      bloc.state,
      const ActionFailure<int>(StorageFailure(code: 'negative')),
    );

    bloc.reset();
    await pumpEventQueue();
    expect(bloc.state, const ActionIdle<int>());
  });

  test('a second run while the first is going is ignored', () async {
    bloc.gate = Completer();
    bloc
      ..run(1)
      ..run(2);
    await pumpEventQueue();
    bloc.gate!.complete();
    await pumpEventQueue();

    expect(bloc.calls, 1);
    expect(bloc.state, const ActionSuccess(2));
  });

  test('an exception in perform() becomes a failure', () async {
    bloc.throwThis = StateError('bug');
    bloc.run(1);
    await pumpEventQueue();

    expect(
      bloc.state.mapOrNull(failure: (s) => s.failure),
      isA<UnexpectedFailure>(),
    );
  });

  test('map helpers', () {
    const ActionState<int> state = ActionInProgress();
    expect(state.isInProgress, isTrue);
    expect(state.mapOrElse(orElse: (_) => 'else', success: (_) => 's'), 'else');
    expect(state.mapOrNull(inProgress: (_) => 'busy'), 'busy');
  });
}
