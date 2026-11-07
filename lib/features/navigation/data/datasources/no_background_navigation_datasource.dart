import 'package:wayback/features/navigation/data/datasources/background_navigation_datasource.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_notice.dart';

/// iOS: navigation works only while the app is open.
final class NoBackgroundNavigationDatasource
    implements BackgroundNavigationDatasource {
  const NoBackgroundNavigationDatasource();

  @override
  Future<void> show(NavigationNotice notice) async {}

  @override
  Future<void> stop() async {}

  @override
  Stream<void> watchStopRequests() => const Stream.empty();
}
