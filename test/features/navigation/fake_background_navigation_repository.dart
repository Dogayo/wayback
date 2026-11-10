import 'dart:async';

import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_notice.dart';
import 'package:wayback/features/navigation/domain/repositories/background_navigation_repository.dart';

final class FakeBackgroundNavigationRepository
    implements BackgroundNavigationRepository {
  final notices = <NavigationNotice>[];
  final stopRequests = StreamController<Result<void>>.broadcast();
  int stops = 0;

  @override
  Future<Result<void>> show(NavigationNotice notice) async {
    notices.add(notice);
    return const Result.success(null);
  }

  @override
  Future<Result<void>> stop() async {
    stops++;
    return const Result.success(null);
  }

  @override
  Stream<Result<void>> watchStopRequests() => stopRequests.stream;
}
