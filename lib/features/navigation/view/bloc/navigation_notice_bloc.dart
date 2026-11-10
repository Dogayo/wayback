import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_notice.dart';
import 'package:wayback/features/navigation/domain/repositories/background_navigation_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Shows the background navigation notice while this bloc is alive, i.e.
/// while the screen is open. A failure shows nothing: navigation on the
/// screen does not depend on it, and the log keeps the state change.
final class NavigationNoticeBloc extends ActionBloc<NavigationNotice, void> {
  NavigationNoticeBloc(this._background);

  final BackgroundNavigationRepository _background;

  @override
  Future<Result<void>> perform(NavigationNotice params) =>
      _background.show(params);

  @override
  Future<void> close() async {
    await _background.stop();
    return super.close();
  }
}
