import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/location/view/bloc/location_fix_bloc.dart';
import 'package:wayback/features/location/view/bloc/open_location_settings_bloc.dart';
import 'package:wayback/features/location/view/bloc/request_location_permission_bloc.dart';

import '../fake_location_repository.dart';

void main() {
  group('LocationFixBloc', () {
    Future<LocationFixBloc> fetch(FakeLocationRepository repository) async {
      final bloc = LocationFixBloc(repository)..fetch();
      addTearDown(bloc.close);
      await pumpEventQueue();
      return bloc;
    }

    test('granted access shows fixes as they come', () async {
      final repository = FakeLocationRepository();
      final bloc = await fetch(repository);
      repository.fixes.add(Result.success(fixWithAccuracy(8)));
      await pumpEventQueue();

      expect(bloc.state, DataSuccess(fixWithAccuracy(8)));
    });

    final cases = {
      LocationAccess.approximate: LocationErrorCodes.preciseRequired,
      LocationAccess.denied: LocationErrorCodes.permissionDenied,
      LocationAccess.deniedForever: LocationErrorCodes.permissionDeniedForever,
      LocationAccess.serviceDisabled: LocationErrorCodes.serviceDisabled,
    };
    for (final MapEntry(key: access, value: code) in cases.entries) {
      test('${access.name} is a failure with $code', () async {
        final bloc = await fetch(
          FakeLocationRepository(access: Result.success(access)),
        );
        expect(bloc.state.mapOrNull(failure: (s) => s.failure.code), code);
      });
    }

    test('a lost fix is a failure and the next fix recovers', () async {
      final repository = FakeLocationRepository();
      final bloc = await fetch(repository);
      repository.fixes
        ..add(const Result.failure(SensorFailure(code: 'location_unavailable')))
        ..add(Result.success(fixWithAccuracy(9)));
      await pumpEventQueue();

      expect(bloc.state, DataSuccess(fixWithAccuracy(9)));
    });
  });

  test('RequestLocationPermissionBloc asks the repository', () async {
    final repository = FakeLocationRepository(
      access: const Result.success(LocationAccess.denied),
    );
    final bloc = RequestLocationPermissionBloc(repository)..run(null);
    addTearDown(bloc.close);
    await pumpEventQueue();

    expect(repository.requests, 1);
    expect(bloc.state, const ActionSuccess(LocationAccess.granted));
  });

  test('OpenLocationSettingsBloc picks the screen by failure code', () async {
    final repository = FakeLocationRepository();
    final bloc = OpenLocationSettingsBloc(repository);
    addTearDown(bloc.close);

    bloc.run(LocationErrorCodes.serviceDisabled);
    await pumpEventQueue();
    bloc.run(LocationErrorCodes.permissionDeniedForever);
    await pumpEventQueue();

    expect(repository.opened, ['location', 'app']);
  });
}
