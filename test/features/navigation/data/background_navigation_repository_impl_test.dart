import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/navigation/data/datasources/background_navigation_datasource.dart';
import 'package:wayback/features/navigation/data/datasources/no_background_navigation_datasource.dart';
import 'package:wayback/features/navigation/data/repositories/background_navigation_repository_impl.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_notice.dart';

const _notice = NavigationNotice(
  title: 'Поле 1',
  text: '320 м',
  stopLabel: 'Стоп',
  channelName: 'Навигация',
);

final class _FailingDatasource implements BackgroundNavigationDatasource {
  const _FailingDatasource();

  @override
  Future<void> show(NavigationNotice notice) async =>
      throw StateError('not allowed in the background');

  @override
  Future<void> stop() async {}

  @override
  Stream<void> watchStopRequests() => const Stream.empty();
}

void main() {
  test(
    'without background navigation nothing happens and nothing fails',
    () async {
      const repository = BackgroundNavigationRepositoryImpl(
        NoBackgroundNavigationDatasource(),
      );

      expect(await repository.show(_notice), isA<Success<void>>());
      expect(await repository.stop(), isA<Success<void>>());
      expect(await repository.watchStopRequests().isEmpty, isTrue);
    },
  );

  test('a refused service is a failure, not an exception', () async {
    final result = await const BackgroundNavigationRepositoryImpl(
      _FailingDatasource(),
    ).show(_notice);

    expect(result, isA<Failed<void>>());
  });
}
