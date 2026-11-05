import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/view/bloc/point_form_bloc.dart';

import '../fake_points_repository.dart';

void main() {
  late FakePointsRepository points;

  Future<PointFormBloc> start() async {
    final bloc = PointFormBloc(
      points,
      labelOf: (type) => switch (type) {
        PointType.car => 'Машина',
        PointType.generic => 'Точка',
        _ => type.name,
      },
      numbered: (label, number) => '$label $number',
    )..add(const PointFormStarted());
    addTearDown(bloc.close);
    await pumpEventQueue();
    return bloc;
  }

  setUp(() => points = FakePointsRepository());

  test('starts with the generic default', () async {
    final bloc = await start();
    expect(bloc.state.name, 'Точка');
    expect(bloc.state.type, PointType.generic);
  });

  test('the default follows the type and skips taken names', () async {
    points.points.add(savedPoint('a', name: 'Машина'));
    final bloc = await start();
    bloc.add(const PointFormTypeSelected(PointType.car));
    await pumpEventQueue();

    expect(bloc.state.name, 'Машина 2');
  });

  test('an edited name stays; an empty one falls back', () async {
    final bloc = await start();
    bloc
      ..add(const PointFormNameEdited('У леса'))
      ..add(const PointFormTypeSelected(PointType.car));
    await pumpEventQueue();
    expect(bloc.state.name, 'У леса');
    expect(bloc.state.resolvedName, 'У леса');

    bloc.add(const PointFormNameEdited('   '));
    await pumpEventQueue();
    expect(bloc.state.resolvedName, 'Машина');
  });
}
