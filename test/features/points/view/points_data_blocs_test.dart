import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/points/domain/repositories/points_repository.dart';
import 'package:wayback/features/points/view/bloc/home_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_details_bloc.dart';
import 'package:wayback/features/points/view/bloc/points_list_bloc.dart';

import '../../location/fake_location_repository.dart';
import '../fake_points_repository.dart';

Future<B> _fetch<B extends DataBloc<Object?>>(B bloc) async {
  addTearDown(bloc.close);
  bloc.fetch();
  await pumpEventQueue();
  return bloc;
}

void main() {
  group('HomeBloc', () {
    test('nothing saved, nothing active, active only', () async {
      final none = await _fetch(
        HomeBloc(FakePointsRepository(), FakeLocationRepository()),
      );
      expect(none.state.dataOrNull!.hasNoPoints, isTrue);

      final inactive = await _fetch(
        HomeBloc(
          FakePointsRepository([savedPoint('a', active: false)]),
          FakeLocationRepository(),
        ),
      );
      expect(inactive.state.dataOrNull!.hasNoActive, isTrue);

      final some = await _fetch(
        HomeBloc(
          FakePointsRepository([
            savedPoint('a'),
            savedPoint('b', active: false),
          ]),
          FakeLocationRepository(),
        ),
      );
      expect(some.state.dataOrNull!.active.map((p) => p.point.id), ['a']);
    });

    test('distances fill in once there is a fix', () async {
      final location = FakeLocationRepository();
      final bloc = await _fetch(
        HomeBloc(FakePointsRepository([savedPoint('a')]), location),
      );
      expect(bloc.state.dataOrNull!.active.single.distanceMeters, isNull);

      location.fixes.add(Result.success(fixWithAccuracy(8)));
      await pumpEventQueue();

      expect(bloc.state.dataOrNull!.active.single.distanceMeters, isNotNull);
    });

    test('unreadable points are a failure', () async {
      final bloc = await _fetch(
        HomeBloc(
          FakePointsRepository()
            ..readFailure = const StorageFailure(
              code: 'points_storage_read_failed',
            ),
          FakeLocationRepository(),
        ),
      );
      expect(bloc.state, isA<DataFailure<HomePoints>>());
    });
  });

  test('PointsListBloc follows every change', () async {
    final points = FakePointsRepository([savedPoint('a')]);
    final bloc = await _fetch(PointsListBloc(points, FakeLocationRepository()));
    expect(bloc.state.dataOrNull, hasLength(1));

    await points.delete('a');
    await pumpEventQueue();

    expect(bloc.state.dataOrNull, isEmpty);
  });

  group('PointDetailsBloc', () {
    test('shows the point and follows its changes', () async {
      final points = FakePointsRepository([savedPoint('a', name: 'Машина')]);
      final bloc = await _fetch(
        PointDetailsBloc(points, FakeLocationRepository(), pointId: 'a'),
      );
      expect(bloc.state.dataOrNull!.point.name, 'Машина');

      await points.rename('a', 'Машина у леса');
      await pumpEventQueue();
      expect(bloc.state.dataOrNull!.point.name, 'Машина у леса');
    });

    test('a missing point is not found', () async {
      final bloc = await _fetch(
        PointDetailsBloc(
          FakePointsRepository(),
          FakeLocationRepository(),
          pointId: 'gone',
        ),
      );
      expect(
        bloc.state.mapOrNull(failure: (s) => s.failure.code),
        PointsErrorCodes.notFound,
      );
    });
  });
}
