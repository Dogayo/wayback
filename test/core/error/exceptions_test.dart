import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/exceptions.dart';

void main() {
  test('carries code, description and cause', () {
    final cause = StateError('disk full');
    final exception = StorageException(
      code: 'points_storage_write_failed',
      description: 'write to points box',
      cause: cause,
    );

    expect(exception, isA<LocalException>());
    expect(exception, isA<Exception>());
    expect(exception.code, 'points_storage_write_failed');
    expect(exception.description, 'write to points box');
    expect(exception.cause, same(cause));
  });

  test('toString includes type, code and description', () {
    const exception = SensorException(
      code: 'navigation_compass_unavailable',
      description: 'no magnetometer',
    );

    expect(
      exception.toString(),
      'SensorException(navigation_compass_unavailable): no magnetometer',
    );
  });

  test('local and remote hierarchies are disjoint', () {
    const AppException local = NotFoundException(code: 'points_not_found');
    const AppException remote = NetworkException(code: 'sync_offline');

    String kind(AppException e) => switch (e) {
      LocalException() => 'local',
      RemoteException() => 'remote',
    };

    expect(kind(local), 'local');
    expect(kind(remote), 'remote');
  });
}
