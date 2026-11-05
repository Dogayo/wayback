part of 'list_bloc.dart';

/// What a loaded list is doing in the background.
enum ListActivity { idle, refreshing, loadingMore }

/// State of a [ListBloc]. The view handles it through [map], [mapOrElse]
/// or [mapOrNull], never with `is` checks.
sealed class ListState<T> {
  const ListState();

  List<T> get itemsOrEmpty => switch (this) {
    ListLoaded(:final items) => items,
    _ => const [],
  };

  R map<R>({
    required R Function(ListInitial<T> state) initial,
    required R Function(ListLoading<T> state) loading,
    required R Function(ListEmpty<T> state) empty,
    required R Function(ListLoaded<T> state) loaded,
    required R Function(ListFailure<T> state) failure,
  }) => switch (this) {
    final ListInitial<T> s => initial(s),
    final ListLoading<T> s => loading(s),
    final ListEmpty<T> s => empty(s),
    final ListLoaded<T> s => loaded(s),
    final ListFailure<T> s => failure(s),
  };

  R mapOrElse<R>({
    required R Function(ListState<T> state) orElse,
    R Function(ListInitial<T> state)? initial,
    R Function(ListLoading<T> state)? loading,
    R Function(ListEmpty<T> state)? empty,
    R Function(ListLoaded<T> state)? loaded,
    R Function(ListFailure<T> state)? failure,
  }) => map(
    initial: initial ?? orElse,
    loading: loading ?? orElse,
    empty: empty ?? orElse,
    loaded: loaded ?? orElse,
    failure: failure ?? orElse,
  );

  R? mapOrNull<R>({
    R Function(ListInitial<T> state)? initial,
    R Function(ListLoading<T> state)? loading,
    R Function(ListEmpty<T> state)? empty,
    R Function(ListLoaded<T> state)? loaded,
    R Function(ListFailure<T> state)? failure,
  }) => mapOrElse<R?>(
    orElse: (_) => null,
    initial: initial,
    loading: loading,
    empty: empty,
    loaded: loaded,
    failure: failure,
  );
}

final class ListInitial<T> extends ListState<T> {
  const ListInitial();

  @override
  bool operator ==(Object other) => other is ListInitial<T>;

  @override
  int get hashCode => (ListInitial<T>).hashCode;
}

final class ListLoading<T> extends ListState<T> {
  const ListLoading();

  @override
  bool operator ==(Object other) => other is ListLoading<T>;

  @override
  int get hashCode => (ListLoading<T>).hashCode;
}

/// The first page came back with nothing in it.
final class ListEmpty<T> extends ListState<T> {
  const ListEmpty();

  @override
  bool operator ==(Object other) => other is ListEmpty<T>;

  @override
  int get hashCode => (ListEmpty<T>).hashCode;
}

final class ListLoaded<T> extends ListState<T> {
  const ListLoaded(
    this.items, {
    this.nextCursor,
    this.activity = ListActivity.idle,
    this.lastFailure,
  });

  final List<T> items;
  final Object? nextCursor;
  final ListActivity activity;

  /// A refresh or next page that failed; the loaded items stay.
  final Failure? lastFailure;

  bool get hasMore => nextCursor != null;

  ListLoaded<T> copyWith({ListActivity? activity, Failure? lastFailure}) =>
      ListLoaded<T>(
        items,
        nextCursor: nextCursor,
        activity: activity ?? this.activity,
        lastFailure: lastFailure,
      );

  @override
  bool operator ==(Object other) =>
      other is ListLoaded<T> &&
      identical(other.items, items) &&
      other.nextCursor == nextCursor &&
      other.activity == activity &&
      other.lastFailure == lastFailure;

  @override
  int get hashCode =>
      Object.hash(ListLoaded<T>, items, nextCursor, activity, lastFailure);
}

final class ListFailure<T> extends ListState<T> {
  const ListFailure(this.failure);

  final Failure failure;

  @override
  bool operator ==(Object other) =>
      other is ListFailure<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(ListFailure<T>, failure);
}
