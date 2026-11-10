import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';

part 'data_event.dart';
part 'data_state.dart';

/// Gets one piece of data and shows it: fetch, refresh, retry.
///
/// Subclasses provide [watch]. A one-shot source is
/// `watch() => repository.load().asStream()`; a changing one returns the
/// repository stream, and every new value replaces the shown one.
///
/// A new fetch, refresh or stop cancels the previous one (`restartable`).
abstract class DataBloc<T> extends Bloc<DataEvent, DataState<T>> {
  DataBloc() : super(DataInitial<T>()) {
    on<DataEvent>(_onEvent, transformer: restartable());
  }

  /// The data source; called again on every fetch and refresh.
  Stream<Result<T>> watch();

  /// Loads from scratch, showing [DataLoading] without previous data.
  void fetch() => add(const DataFetched());

  /// Loads again while the current data stays on screen.
  void refresh() => add(const DataRefreshed());

  /// Stops listening to [watch]; the state stays, [refresh] picks it up.
  void stop() => add(const DataStopped());

  Future<void> _onEvent(DataEvent event, Emitter<DataState<T>> emit) async {
    if (event is DataStopped) return;
    final previous = event is DataRefreshed ? state.dataOrNull : null;
    emit(DataLoading<T>(previous: previous));
    await emit.forEach<Result<T>>(
      watch(),
      onData: (result) => switch (result) {
        Success(:final value) => DataSuccess<T>(value),
        Failed(:final failure) => DataFailure<T>(
          failure,
          previous: state.dataOrNull,
        ),
      },
      // Repositories never throw; this guards logic in watch() itself.
      onError: (error, stackTrace) => DataFailure<T>(
        UnexpectedFailure(
          description: '$error',
          cause: error,
          stackTrace: stackTrace,
        ),
        previous: state.dataOrNull,
      ),
    );
  }
}
