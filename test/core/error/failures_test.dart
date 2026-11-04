import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';

void main() {
  test('failures with the same type, code and description are equal', () {
    expect(
      const StorageFailure(
        code: 'points_storage_read_failed',
        description: 'x',
      ),
      const StorageFailure(
        code: 'points_storage_read_failed',
        description: 'x',
      ),
    );
  });

  test('type, code and description all take part in equality', () {
    const base = PermissionFailure(code: 'location_permission_denied');

    expect(
      base,
      isNot(const SensorFailure(code: 'location_permission_denied')),
    );
    expect(
      base,
      isNot(const PermissionFailure(code: 'location_permission_forever')),
    );
    expect(
      base,
      isNot(
        const PermissionFailure(
          code: 'location_permission_denied',
          description: 'denied in settings',
        ),
      ),
    );
  });

  test('cause and stack trace do not affect equality', () {
    expect(
      PermissionFailure(code: 'a', cause: Exception('one')),
      PermissionFailure(code: 'a', cause: Exception('two')),
    );
  });

  test('every subtype is matched exhaustively', () {
    const failures = <Failure>[
      StorageFailure(code: 'a'),
      PermissionFailure(code: 'a'),
      SensorFailure(code: 'a'),
      NotFoundFailure(code: 'a'),
      NetworkFailure(code: 'a'),
      TimeoutFailure(code: 'a'),
      ServerFailure(code: 'a'),
    ];

    String kind(Failure f) => switch (f) {
      LocalFailure() => 'local',
      RemoteFailure() => 'remote',
      UnexpectedFailure() => 'unexpected',
    };

    expect(failures.map(kind), [
      ...List.filled(4, 'local'),
      ...List.filled(3, 'remote'),
    ]);
  });
}
