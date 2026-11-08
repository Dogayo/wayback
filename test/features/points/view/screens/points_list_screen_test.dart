import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/features/points/view/bloc/delete_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/points_list_bloc.dart';
import 'package:wayback/features/points/view/bloc/rename_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/set_point_active_bloc.dart';
import 'package:wayback/features/points/view/screens/points_list_screen.dart';

import '../../../location/fake_location_repository.dart';
import '../../fake_points_repository.dart';
import 'screen_host.dart';

Future<void> _pump(WidgetTester tester, FakePointsRepository points) async {
  await pumpScreen(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              PointsListBloc(points, FakeLocationRepository())..fetch(),
        ),
        BlocProvider(create: (_) => RenamePointBloc(points)),
        BlocProvider(create: (_) => SetPointActiveBloc(points)),
        BlocProvider(create: (_) => DeletePointBloc(points)),
      ],
      child: const PointsListScreen(),
    ),
    points: points,
  );
  await settle(tester);
}

void main() {
  testWidgets('no points: empty state and Save', (tester) async {
    await _pump(tester, FakePointsRepository());

    expect(find.text('Нет сохранённых точек'), findsOneWidget);
    expect(find.text('Сохранить место'), findsOneWidget);
  });

  testWidgets('points with save time, activity and navigation', (tester) async {
    await _pump(
      tester,
      FakePointsRepository([
        savedPoint('a', name: 'Машина'),
        savedPoint('b', name: 'Лагерь', active: false),
      ]),
    );

    expect(find.text('Машина'), findsOneWidget);
    expect(find.text('Лагерь'), findsOneWidget);
    expect(find.text('Активна'), findsOneWidget);
    expect(find.textContaining('сохранено'), findsNWidgets(2));

    await tester.tap(find.text('Лагерь'));
    await settle(tester);
    expect(find.text('route /points/b'), findsOneWidget);
  });

  testWidgets('unreadable storage: error with retry', (tester) async {
    await _pump(
      tester,
      FakePointsRepository()
        ..readFailure = const StorageFailure(
          code: 'points_storage_read_failed',
        ),
    );

    expect(find.text('Не удалось загрузить точки'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });

  group('swipe', () {
    Future<void> swipe(WidgetTester tester, String row) async {
      await tester.drag(find.text(row), const Offset(-300, 0));
      await settle(tester);
    }

    testWidgets('shows the actions and changes nothing by itself', (
      tester,
    ) async {
      final points = FakePointsRepository([savedPoint('a', name: 'Машина')]);
      await _pump(tester, points);

      await swipe(tester, 'Машина');

      expect(find.text('Отключить'), findsOneWidget);
      expect(find.text('Переименовать'), findsOneWidget);
      expect(find.text('Удалить'), findsOneWidget);
      expect(points.points.single.isActive, isTrue);
    });

    testWidgets('an inactive point offers to turn it on', (tester) async {
      final points = FakePointsRepository([
        savedPoint('a', name: 'Машина', active: false),
      ]);
      await _pump(tester, points);
      await swipe(tester, 'Машина');

      await tester.tap(find.text('Включить'));
      await settle(tester);

      expect(points.points.single.isActive, isTrue);
      expect(find.text('Вернуть'), findsNothing);
    });

    testWidgets('delete confirms, removes the row and can be undone', (
      tester,
    ) async {
      final points = FakePointsRepository([
        savedPoint('a', name: 'Машина'),
        savedPoint('b', name: 'Лагерь'),
      ]);
      await _pump(tester, points);
      await swipe(tester, 'Машина');

      await tester.tap(find.text('Удалить'));
      await settle(tester);
      await tester.tap(find.text('Удалить').last);
      await settle(tester);

      expect(find.text('Машина'), findsNothing);
      expect(find.text('Точка «Машина» удалена'), findsOneWidget);

      await tester.tap(find.text('Вернуть'));
      await settle(tester);
      expect(find.text('Машина'), findsOneWidget);
    });

    testWidgets('a long press offers the same actions', (tester) async {
      await _pump(
        tester,
        FakePointsRepository([savedPoint('a', name: 'Машина', active: false)]),
      );

      await tester.longPress(find.text('Машина'));
      await settle(tester);

      expect(find.text('Сделать активной'), findsOneWidget);
    });
  });

  group('adding', () {
    testWidgets('+ offers both ways', (tester) async {
      await _pump(tester, FakePointsRepository([savedPoint('a')]));

      await tester.tap(find.byTooltip('Новая точка').first);
      await settle(tester);

      expect(find.text('Текущее место'), findsOneWidget);
      expect(find.text('По координатам'), findsOneWidget);
    });

    testWidgets('by coordinates opens the form', (tester) async {
      await _pump(tester, FakePointsRepository([savedPoint('a')]));
      await tester.tap(find.byTooltip('Новая точка').first);
      await settle(tester);

      await tester.tap(find.text('По координатам'));
      await settle(tester);

      expect(find.text('route /import'), findsOneWidget);
    });
  });
}
