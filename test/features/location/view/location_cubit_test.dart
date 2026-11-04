import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/location/view/bloc/location_cubit.dart';

import '../fake_location_repository.dart';

void main() {
  late FakeLocationRepository repository;
  late LocationCubit cubit;

  void setUpWith(LocationAccess access, {LocationAccess? afterRequest}) {
    repository = FakeLocationRepository(
      access: Result.success(access),
      afterRequest: afterRequest,
    );
    cubit = LocationCubit(repository);
    addTearDown(cubit.close);
  }

  test('granted access listens and shows fixes', () async {
    setUpWith(LocationAccess.granted);
    await cubit.start();
    expect(cubit.state, isA<LocationLoading>());

    repository.fixes.add(Result.success(fixWithAccuracy(8)));
    await pumpEventQueue();

    expect(cubit.state, LocationReady(fixWithAccuracy(8)));
  });

  test('denied access waits for the user to allow', () async {
    setUpWith(LocationAccess.denied);
    await cubit.start();

    expect(cubit.state, isA<LocationPermissionNeeded>());
    expect(repository.requests, 0);
  });

  test('allowing from the prompt starts listening', () async {
    setUpWith(LocationAccess.denied, afterRequest: LocationAccess.granted);
    await cubit.start();
    await cubit.requestPermission();
    repository.fixes.add(Result.success(fixWithAccuracy(12)));
    await pumpEventQueue();

    expect(repository.requests, 1);
    expect(cubit.state, LocationReady(fixWithAccuracy(12)));
  });

  test('refusing in the dialog for good shows the settings error', () async {
    setUpWith(
      LocationAccess.denied,
      afterRequest: LocationAccess.deniedForever,
    );
    await cubit.start();
    await cubit.requestPermission();

    expect(
      cubit.state,
      const LocationError(
        PermissionFailure(code: LocationErrorCodes.permissionDeniedForever),
      ),
    );
    await cubit.openSettings();
    expect(repository.opened, ['app']);
  });

  test('disabled service points to the location settings', () async {
    setUpWith(LocationAccess.serviceDisabled);
    await cubit.start();

    expect(
      cubit.state,
      const LocationError(
        SensorFailure(code: LocationErrorCodes.serviceDisabled),
      ),
    );
    await cubit.openSettings();
    expect(repository.opened, ['location']);
  });

  test('a lost fix is an error and the next fix recovers', () async {
    setUpWith(LocationAccess.granted);
    await cubit.start();

    repository.fixes.add(
      const Result.failure(SensorFailure(code: LocationErrorCodes.unavailable)),
    );
    await pumpEventQueue();
    expect(cubit.state, isA<LocationError>());

    repository.fixes.add(Result.success(fixWithAccuracy(9)));
    await pumpEventQueue();
    expect(cubit.state, LocationReady(fixWithAccuracy(9)));
  });

  test('a failing access check is shown as an error', () async {
    repository = FakeLocationRepository(
      access: const Result.failure(
        SensorFailure(code: LocationErrorCodes.unavailable),
      ),
    );
    cubit = LocationCubit(repository);
    addTearDown(cubit.close);
    await cubit.start();

    expect(cubit.state, isA<LocationError>());
  });
}
