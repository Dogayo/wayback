import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';

part 'list_event.dart';
part 'list_state.dart';

/// One page of a list and where the next one starts.
final class ListPage<T> {
  const ListPage(this.items, {this.nextCursor});

  final List<T> items;

  /// Opaque position of the next page; `null` when this was the last one.
  final Object? nextCursor;
}

/// A paged list: fetch, refresh, fetch more.
///
/// A fetch or refresh cancels the previous one (`restartable`); a request
/// for more while a page loads is ignored (`droppable`).
abstract class ListBloc<T> extends Bloc<ListEvent, ListState<T>> {
  ListBloc() : super(ListInitial<T>()) {
    on<ListReloadEvent>(_onReload, transformer: restartable());
    on<ListMoreRequested>(_onMore, transformer: droppable());
  }

  /// One page; [cursor] is `null` for the first one.
  Future<Result<ListPage<T>>> fetchPage(Object? cursor);

  void fetch() => add(const ListFetched());

  void refresh() => add(const ListRefreshed());

  void fetchMore() => add(const ListMoreRequested());

  Future<void> _onReload(
    ListReloadEvent event,
    Emitter<ListState<T>> emit,
  ) async {
    final current = state;
    if (event is ListRefreshed && current is ListLoaded<T>) {
      emit(current.copyWith(activity: ListActivity.refreshing));
    } else {
      emit(ListLoading<T>());
    }
    final result = await _guard(null);
    emit(switch ((result, current)) {
      (Success(:final value), _) =>
        value.items.isEmpty && value.nextCursor == null
            ? ListEmpty<T>()
            : ListLoaded<T>(value.items, nextCursor: value.nextCursor),
      // A failed refresh keeps the list and reports the failure once.
      (Failed(:final failure), final ListLoaded<T> loaded)
          when event is ListRefreshed =>
        loaded.copyWith(activity: ListActivity.idle, lastFailure: failure),
      (Failed(:final failure), _) => ListFailure<T>(failure),
    });
  }

  Future<void> _onMore(
    ListMoreRequested event,
    Emitter<ListState<T>> emit,
  ) async {
    final current = state;
    if (current is! ListLoaded<T> ||
        !current.hasMore ||
        current.activity != ListActivity.idle) {
      return;
    }
    emit(current.copyWith(activity: ListActivity.loadingMore));
    final result = await _guard(current.nextCursor);
    emit(switch (result) {
      Success(:final value) => ListLoaded<T>([
        ...current.items,
        ...value.items,
      ], nextCursor: value.nextCursor),
      Failed(:final failure) => current.copyWith(lastFailure: failure),
    });
  }

  Future<Result<ListPage<T>>> _guard(Object? cursor) async {
    try {
      return await fetchPage(cursor);
    } on Object catch (error, stackTrace) {
      // Repositories never throw; this guards logic in fetchPage() itself.
      return Result.failure(
        UnexpectedFailure(
          description: '$error',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
