import 'package:wayback/features/navigation/domain/entities/navigation_notice.dart';

abstract interface class BackgroundNavigationDatasource {
  Future<void> show(NavigationNotice notice);

  Future<void> stop();

  Stream<void> watchStopRequests();
}
