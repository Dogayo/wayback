import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/navigation/view/bloc/point_directions_bloc.dart';

import '../../../location/fake_location_repository.dart';
import '../../../points/fake_points_repository.dart';
import '../../fake_compass_repository.dart';

void main() {
  late FakeLocationRepository location;
  late FakeCompassRepository compass;
  late PointDirectionsBloc bloc;

  setUp(() {
    location = FakeLocationRepository();
    compass = FakeCompassRepository();
    bloc = PointDirectionsBloc(
      FakePointsRepository([savedPoint('a'), savedPoint('b', active: false)]),
      location,
      compass,
    );
    addTearDown(bloc.close);
  });

  Future<void> locateAndTurn(double degrees) async {
    location.fixes.add(Result.success(fixWithAccuracy(8)));
    await pumpEventQueue();
    compass.readings.add(Result.success(heading(degrees)));
    await pumpEventQueue();
  }

  test('only active points get an arrow', () async {
    bloc.refresh();
    await pumpEventQueue();
    await locateAndTurn(0);

    expect(bloc.state.dataOrNull?.arrows.keys, ['a']);
  });

  test('stop releases the compass, refresh takes it back', () async {
    bloc.refresh();
    await pumpEventQueue();
    await locateAndTurn(0);
    final arrow = bloc.state.dataOrNull?.arrows['a'];

    bloc.stop();
    await pumpEventQueue();
    expect(compass.isListened, isFalse);
    expect(location.fixes.hasListener, isFalse);
    expect(bloc.state.dataOrNull?.arrows['a'], arrow);

    bloc.refresh();
    await pumpEventQueue();
    expect(compass.isListened, isTrue);
  });

  test('after a pause the arrow goes on from where it was', () async {
    bloc.refresh();
    await pumpEventQueue();
    await locateAndTurn(0);
    await locateAndTurn(180);
    await locateAndTurn(350);
    final arrow = bloc.state.dataOrNull!.arrows['a']!;

    bloc.stop();
    await pumpEventQueue();
    bloc.refresh();
    await pumpEventQueue();
    await locateAndTurn(350);

    expect(bloc.state.dataOrNull?.arrows['a'], closeTo(arrow, 1e-6));
  });
}
