import 'package:app_logger/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs when a bloc moves to another kind of state, e.g. loading to failure.
/// New data in the same state is skipped: it comes many times a second, and
/// states may hold what must not be logged, such as point names.
final class LogBlocObserver extends BlocObserver {
  const LogBlocObserver(this._logger);

  final AppLogger _logger;

  static String _name(Object? state) => '${state.runtimeType}'.split('<').first;

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    final from = _name(change.currentState);
    final to = _name(change.nextState);
    if (from == to) return;
    _logger.debug(
      'bloc',
      '${bloc.runtimeType}',
      fields: {'from': from, 'to': to},
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.error(
      'bloc',
      '${bloc.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
