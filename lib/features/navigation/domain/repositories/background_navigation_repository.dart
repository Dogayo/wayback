import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_notice.dart';

/// Keeps navigation alive with the screen off (mvp-scope.md §2.8). Does
/// nothing where background navigation is not supported.
///
/// Every method returns a [Result]; none of them throws.
abstract interface class BackgroundNavigationRepository {
  /// Starts background navigation with [notice], or updates the notice if it
  /// runs already. The start needs the app in the foreground and location
  /// access granted.
  Future<Result<void>> show(NavigationNotice notice);

  Future<Result<void>> stop();

  /// An event each time the user presses Stop on the notice.
  Stream<Result<void>> watchStopRequests();
}
