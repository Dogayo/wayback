import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/navigation/view/bloc/point_directions_bloc.dart';
import 'package:wayback/features/navigation/view/widgets/point_direction.dart';
import 'package:wayback/features/navigation/view/widgets/point_directions_gate.dart';
import 'package:wayback/features/points/view/bloc/delete_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/edit_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/home_bloc.dart';
import 'package:wayback/features/points/view/bloc/quick_save_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/set_point_active_bloc.dart';
import 'package:wayback/features/points/view/screens/home_screen.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

import '../../../location/fake_location_repository.dart';
import '../../../points/fake_points_repository.dart';
import '../../../points/view/screens/screen_host.dart';
import '../../fake_compass_repository.dart';

typedef _Home = ({
  GoRouter router,
  FakeLocationRepository location,
  FakeCompassRepository compass,
});

Future<_Home> _pump(WidgetTester tester, {bool large = false}) async {
  final points = FakePointsRepository([savedPoint('a', name: 'Машина')]);
  final location = FakeLocationRepository();
  final compass = FakeCompassRepository();
  final router = await pumpScreen(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeBloc(points, location)..fetch()),
        BlocProvider(create: (_) => SetPointActiveBloc(points)),
        BlocProvider(create: (_) => DeletePointBloc(points)),
        BlocProvider(create: (_) => EditPointBloc(points)),
        BlocProvider(
          create: (_) => QuickSavePointBloc(
            points,
            location,
            label: 'Точка',
            numbered: (label, number) => '$label $number',
          ),
        ),
        BlocProvider(
          create: (_) => PointDirectionsBloc(points, location, compass),
        ),
      ],
      child: PointDirectionsGate(
        child: HomeScreen(
          direction: (pointId, icon) => PointDirection(pointId, icon: icon),
          largeDirection: large
              ? (pointId, icon) =>
                    PointDirection(pointId, icon: icon, large: true)
              : null,
        ),
      ),
    ),
  );
  await settle(tester);
  return (router: router, location: location, compass: compass);
}

Future<void> _locate(WidgetTester tester, _Home home) async {
  home.location.fixes.add(Result.success(fixWithAccuracy(8)));
  await settle(tester);
}

Future<void> _turn(WidgetTester tester, _Home home, double degrees) async {
  home.compass.readings.add(Result.success(heading(degrees)));
  await settle(tester);
}

/// Stream cancels finish outside the test clock, and a restart waits for
/// them, so a resume needs real time before it is seen.
Future<void> _resume(WidgetTester tester) async {
  await tester.runAsync(pumpEventQueue);
  await settle(tester);
}

WbDirectionArrow _arrow(WidgetTester tester) =>
    tester.widget(find.byType(WbDirectionArrow));

void main() {
  testWidgets('without a fix or a compass the dial shows no arrow', (
    tester,
  ) async {
    final home = await _pump(tester);
    expect(find.byType(WbDirectionArrow), findsNothing);

    await _turn(tester, home, 10);
    expect(find.byType(WbDirectionArrow), findsNothing);
  });

  testWidgets('alone on Home the point gets the full dial', (tester) async {
    final home = await _pump(tester, large: true);
    expect(find.byType(WbDirectionIcon), findsOneWidget);

    await _locate(tester, home);
    home.compass.readings.add(Result.success(heading(10, accuracy: 20)));
    await settle(tester);

    final dial = tester.widget<WbDirectionDial>(find.byType(WbDirectionDial));
    expect(dial.size, WbPointHeroCard.dialSize);
    expect(dial.spread, 20);
  });

  testWidgets('the arrow turns against the heading', (tester) async {
    final home = await _pump(tester);
    await _locate(tester, home);
    await _turn(tester, home, 10);
    final first = _arrow(tester).rotation;

    await _turn(tester, home, 40);
    expect(_arrow(tester).rotation, closeTo(first - 30, 1e-6));
  });

  testWidgets('an unreliable compass paints the arrow in warning', (
    tester,
  ) async {
    final home = await _pump(tester);
    await _locate(tester, home);
    await _turn(tester, home, 10);
    expect(_arrow(tester).color, WbColors.light.brand600);

    home.compass.readings.add(Result.success(heading(10, accuracy: 45)));
    await settle(tester);
    expect(_arrow(tester).color, WbColors.light.warning);
  });

  testWidgets('a failed compass falls back to the type icon', (tester) async {
    final home = await _pump(tester);
    await _locate(tester, home);
    await _turn(tester, home, 10);

    home.compass.readings.add(
      const Result.failure(StorageFailure(code: 'compass')),
    );
    await settle(tester);
    expect(find.byType(WbDirectionArrow), findsNothing);
  });

  testWidgets('the compass stops under another route and comes back', (
    tester,
  ) async {
    final home = await _pump(tester);
    expect(home.compass.isListened, isTrue);

    unawaited(home.router.push('/settings'));
    await tester.pumpAndSettle();
    expect(home.compass.isListened, isFalse);

    home.router.pop();
    await tester.pumpAndSettle();
    await _resume(tester);
    expect(home.compass.isListened, isTrue);
  });

  testWidgets('the compass stops in the background', (tester) async {
    final home = await _pump(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await settle(tester);
    expect(home.compass.isListened, isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _resume(tester);
    expect(home.compass.isListened, isTrue);
  });

  testWidgets('the arrow does not spin round after a pause', (tester) async {
    final home = await _pump(tester);
    await _locate(tester, home);
    await _turn(tester, home, 350);
    await _turn(tester, home, 10);
    final before = _arrow(tester).rotation;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await settle(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await _resume(tester);
    expect(home.compass.isListened, isTrue);
    await _locate(tester, home);
    await _turn(tester, home, 10);

    expect(_arrow(tester).rotation, closeTo(before, 1e-6));
  });
}
