import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/bloc/list/list_bloc.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';

/// Pages of three numbers, [pages] pages in total.
final class _Numbers extends ListBloc<int> {
  _Numbers({this.pages = 2});

  int pages;
  bool fail = false;
  final cursors = <Object?>[];

  @override
  Future<Result<ListPage<int>>> fetchPage(Object? cursor) async {
    cursors.add(cursor);
    if (fail) return const Result.failure(StorageFailure(code: 'read'));
    final page = (cursor as int?) ?? 0;
    if (pages == 0) return const Result.success(ListPage([]));
    return Result.success(
      ListPage([
        for (var i = 0; i < 3; i++) page * 3 + i,
      ], nextCursor: page + 1 < pages ? page + 1 : null),
    );
  }
}

void main() {
  test('fetch and fetch more until the last page', () async {
    final bloc = _Numbers();
    addTearDown(bloc.close);

    bloc.fetch();
    await pumpEventQueue();
    expect(bloc.state.itemsOrEmpty, [0, 1, 2]);

    bloc.fetchMore();
    await pumpEventQueue();
    expect(bloc.state.itemsOrEmpty, [0, 1, 2, 3, 4, 5]);
    expect((bloc.state as ListLoaded<int>).hasMore, isFalse);

    bloc.fetchMore();
    await pumpEventQueue();
    expect(bloc.cursors, [null, 1]);
  });

  test('an empty first page is the empty state', () async {
    final bloc = _Numbers(pages: 0);
    addTearDown(bloc.close);
    bloc.fetch();
    await pumpEventQueue();

    expect(bloc.state, const ListEmpty<int>());
  });

  test(
    'a failed first page is a failure; a failed refresh keeps items',
    () async {
      final bloc = _Numbers()..fail = true;
      addTearDown(bloc.close);
      bloc.fetch();
      await pumpEventQueue();
      expect(bloc.state, isA<ListFailure<int>>());

      bloc
        ..fail = false
        ..fetch();
      await pumpEventQueue();
      bloc
        ..fail = true
        ..refresh();
      await pumpEventQueue();

      final state = bloc.state as ListLoaded<int>;
      expect(state.items, [0, 1, 2]);
      expect(state.lastFailure?.code, 'read');
      expect(state.activity, ListActivity.idle);
    },
  );

  test('a failed next page keeps the loaded items', () async {
    final bloc = _Numbers();
    addTearDown(bloc.close);
    bloc.fetch();
    await pumpEventQueue();

    bloc
      ..fail = true
      ..fetchMore();
    await pumpEventQueue();

    final state = bloc.state as ListLoaded<int>;
    expect(state.items, [0, 1, 2]);
    expect(state.lastFailure, isNotNull);
    expect(state.hasMore, isTrue);
  });

  test('map helpers', () {
    const ListState<int> state = ListEmpty();
    expect(
      state.map(
        initial: (_) => 'i',
        loading: (_) => 'l',
        empty: (_) => 'e',
        loaded: (_) => 'd',
        failure: (_) => 'f',
      ),
      'e',
    );
    expect(state.mapOrNull(loaded: (_) => 'd'), isNull);
  });
}
