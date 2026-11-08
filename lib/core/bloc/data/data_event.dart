part of 'data_bloc.dart';

sealed class DataEvent {
  const DataEvent();
}

/// Load from scratch; also the retry after a failure.
final class DataFetched extends DataEvent {
  const DataFetched();
}

/// Load again, keeping the current data visible meanwhile.
final class DataRefreshed extends DataEvent {
  const DataRefreshed();
}

/// Stop listening to the source, keeping the current state.
final class DataStopped extends DataEvent {
  const DataStopped();
}
