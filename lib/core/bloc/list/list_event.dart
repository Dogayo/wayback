part of 'list_bloc.dart';

sealed class ListEvent {
  const ListEvent();
}

/// Events that load the list from its first page.
sealed class ListReloadEvent extends ListEvent {
  const ListReloadEvent();
}

/// First page from scratch; also the retry after a failure.
final class ListFetched extends ListReloadEvent {
  const ListFetched();
}

/// First page again, keeping the loaded items visible meanwhile.
final class ListRefreshed extends ListReloadEvent {
  const ListRefreshed();
}

/// The next page, appended to the loaded items.
final class ListMoreRequested extends ListEvent {
  const ListMoreRequested();
}
