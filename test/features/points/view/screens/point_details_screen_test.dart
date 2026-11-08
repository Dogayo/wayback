import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/features/points/view/bloc/delete_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_details_bloc.dart';
import 'package:wayback/features/points/view/bloc/rename_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/set_point_active_bloc.dart';
import 'package:wayback/features/points/view/screens/point_details_screen.dart';

import '../../../location/fake_location_repository.dart';
import '../../fake_points_repository.dart';
import 'screen_host.dart';

Future<FakePointsRepository> _pump(WidgetTester tester, String id) async {
  final points = FakePointsRepository([savedPoint('a', name: 'Машина')]);
  await pumpScreen(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              PointDetailsBloc(points, FakeLocationRepository(), pointId: id)
                ..fetch(),
        ),
        BlocProvider(create: (_) => RenamePointBloc(points)),
        BlocProvider(create: (_) => SetPointActiveBloc(points)),
        BlocProvider(create: (_) => DeletePointBloc(points)),
      ],
      child: const PointDetailsScreen(),
    ),
    points: points,
  );
  await settle(tester);
  return points;
}

void main() {
  testWidgets('shows the point and switches its activity', (tester) async {
    final points = await _pump(tester, 'a');

    expect(find.text('Машина'), findsWidgets);
    expect(find.text('55.75000, 37.61000'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await settle(tester);
    expect(points.points.single.isActive, isFalse);
  });

  testWidgets('delete asks first, then leaves for the list', (tester) async {
    final points = await _pump(tester, 'a');

    await tester.tap(find.text('Удалить'));
    await settle(tester);
    expect(find.text('Удалить «Машина»?'), findsOneWidget);

    await tester.tap(find.text('Удалить').last);
    await settle(tester);

    expect(points.points, isEmpty);
    expect(find.text('route /points'), findsOneWidget);
    expect(find.text('Точка «Машина» удалена'), findsOneWidget);
    await expireUndo(tester);
  });

  testWidgets('undo after leaving for the list brings the point back', (
    tester,
  ) async {
    final points = await _pump(tester, 'a');
    await tester.tap(find.text('Удалить'));
    await settle(tester);
    await tester.tap(find.text('Удалить').last);
    await settle(tester);

    await tester.tap(find.text('Вернуть'));
    await settle(tester);

    expect(points.points.single.name, 'Машина');
    expect(find.text('Вернуть'), findsNothing);
  });

  testWidgets('a missing point offers the way back', (tester) async {
    await _pump(tester, 'gone');

    expect(find.text('Точка не найдена'), findsOneWidget);
    await tester.tap(find.text('К списку точек'));
    await settle(tester);
    expect(find.text('route /points'), findsOneWidget);
  });
}
