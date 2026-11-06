import 'package:wayback/core/bloc/data/data_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/navigation/domain/repositories/background_navigation_repository.dart';

export 'package:wayback/core/bloc/data/data_bloc.dart';

/// Hears Stop on the background navigation notice.
final class NavigationStopBloc extends DataBloc<void> {
  NavigationStopBloc(this._background);

  final BackgroundNavigationRepository _background;

  @override
  Stream<Result<void>> watch() => _background.watchStopRequests();
}
