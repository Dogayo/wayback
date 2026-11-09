import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/view/bloc/delete_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/edit_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/save_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/set_point_active_bloc.dart';

import '../../location/fake_location_repository.dart';
import '../fake_points_repository.dart';

Future<void> _settle() => pumpEventQueue();

void main() {
  late FakePointsRepository points;

  setUp(() => points = FakePointsRepository([savedPoint('a', name: 'Машина')]));

  test('SavePointBloc saves an active point at the fix', () async {
    final bloc = SavePointBloc(points);
    addTearDown(bloc.close);
    final fix = fixWithAccuracy(8);
    bloc.run((
      name: 'Лагерь',
      type: PointType.tent,
      position: fix.point,
      altitudeMeters: fix.altitudeMeters,
    ));
    await _settle();

    final saved = bloc.state.mapOrNull(success: (s) => s.result)!;
    expect(saved.name, 'Лагерь');
    expect(saved.isActive, isTrue);
    expect(
      saved.position,
      const GeoPoint(latitude: 55.7558, longitude: 37.6173),
    );
  });

  test('a failed save is a failure state', () async {
    points.failNext = const StorageFailure(code: 'points_storage_write_failed');
    final bloc = SavePointBloc(points);
    addTearDown(bloc.close);
    final fix = fixWithAccuracy(8);
    bloc.run((
      name: 'x',
      type: PointType.car,
      position: fix.point,
      altitudeMeters: fix.altitudeMeters,
    ));
    await _settle();

    expect(
      bloc.state.mapOrNull(failure: (s) => s.failure.code),
      'points_storage_write_failed',
    );
  });

  test('edit, activity and delete each change the point', () async {
    final edit = EditPointBloc(points);
    final active = SetPointActiveBloc(points);
    final delete = DeletePointBloc(points);
    addTearDown(edit.close);
    addTearDown(active.close);
    addTearDown(delete.close);

    edit.run((id: 'a', name: 'Машина у леса', type: PointType.fishing));
    await _settle();
    expect(points.points.single.name, 'Машина у леса');
    expect(points.points.single.type, PointType.fishing);

    active.run((id: 'a', active: false));
    await _settle();
    expect(points.points.single.isActive, isFalse);

    delete.run(savedPoint('a'));
    await _settle();
    expect(points.points, isEmpty);
    expect(delete.state, isA<ActionSuccess<SavedPoint>>());
  });
}
