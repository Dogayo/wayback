part of 'data_bloc.dart';

/// State of a [DataBloc]. The view handles it through [map], [mapOrElse]
/// or [mapOrNull], never with `is` checks.
sealed class DataState<T> {
  const DataState();

  /// The latest data, also while reloading or after a failed refresh.
  T? get dataOrNull => switch (this) {
    DataSuccess(:final data) => data,
    DataLoading(:final previous) || DataFailure(:final previous) => previous,
    DataInitial() => null,
  };

  R map<R>({
    required R Function(DataInitial<T> state) initial,
    required R Function(DataLoading<T> state) loading,
    required R Function(DataSuccess<T> state) success,
    required R Function(DataFailure<T> state) failure,
  }) => switch (this) {
    final DataInitial<T> s => initial(s),
    final DataLoading<T> s => loading(s),
    final DataSuccess<T> s => success(s),
    final DataFailure<T> s => failure(s),
  };

  R mapOrElse<R>({
    required R Function(DataState<T> state) orElse,
    R Function(DataInitial<T> state)? initial,
    R Function(DataLoading<T> state)? loading,
    R Function(DataSuccess<T> state)? success,
    R Function(DataFailure<T> state)? failure,
  }) => map(
    initial: initial ?? orElse,
    loading: loading ?? orElse,
    success: success ?? orElse,
    failure: failure ?? orElse,
  );

  R? mapOrNull<R>({
    R Function(DataInitial<T> state)? initial,
    R Function(DataLoading<T> state)? loading,
    R Function(DataSuccess<T> state)? success,
    R Function(DataFailure<T> state)? failure,
  }) => mapOrElse<R?>(
    orElse: (_) => null,
    initial: initial,
    loading: loading,
    success: success,
    failure: failure,
  );
}

final class DataInitial<T> extends DataState<T> {
  const DataInitial();

  @override
  bool operator ==(Object other) => other is DataInitial<T>;

  @override
  int get hashCode => (DataInitial<T>).hashCode;
}

final class DataLoading<T> extends DataState<T> {
  const DataLoading({this.previous});

  /// Data shown while a refresh runs; `null` on a fresh fetch.
  final T? previous;

  @override
  bool operator ==(Object other) =>
      other is DataLoading<T> && other.previous == previous;

  @override
  int get hashCode => Object.hash(DataLoading<T>, previous);
}

final class DataSuccess<T> extends DataState<T> {
  const DataSuccess(this.data);

  final T data;

  @override
  bool operator ==(Object other) =>
      other is DataSuccess<T> && other.data == data;

  @override
  int get hashCode => Object.hash(DataSuccess<T>, data);
}

final class DataFailure<T> extends DataState<T> {
  const DataFailure(this.failure, {this.previous});

  final Failure failure;

  /// Data from before the failure, if there was any.
  final T? previous;

  @override
  bool operator ==(Object other) =>
      other is DataFailure<T> &&
      other.failure == failure &&
      other.previous == previous;

  @override
  int get hashCode => Object.hash(DataFailure<T>, failure, previous);
}
