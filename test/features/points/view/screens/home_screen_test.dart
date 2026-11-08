import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/view/bloc/location_fix_bloc.dart';
import 'package:wayback/features/location/view/bloc/open_location_settings_bloc.dart';
import 'package:wayback/features/location/view/bloc/request_location_permission_bloc.dart';
import 'package:wayback/features/location/view/widgets/gps_status.dart';
import 'package:wayback/features/points/view/bloc/delete_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/home_bloc.dart';
import 'package:wayback/features/points/view/bloc/rename_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/set_point_active_bloc.dart';
import 'package:wayback/features/points/view/screens/home_screen.dart';

import '../../../location/fake_location_repository.dart';
import '../../fake_points_repository.dart';
import 'screen_host.dart';

Future<FakeLocationRepository> _pump(
  WidgetTester tester,
  FakePointsRepository points,
) async {
  final location = FakeLocationRepository(
    access: const Result.success(LocationAccess.denied),
  );
  await pumpScreen(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocationFixBloc(location)..fetch()),
        BlocProvider(create: (_) => RequestLocationPermissionBloc(location)),
        BlocProvider(create: (_) => OpenLocationSettingsBloc(location)),
        BlocProvider(create: (_) => HomeBloc(points, location)..fetch()),
        BlocProvider(create: (_) => RenamePointBloc(points)),
        BlocProvider(create: (_) => SetPointActiveBloc(points)),
        BlocProvider(create: (_) => DeletePointBloc(points)),
      ],
      child: const HomeScreen(gpsStatus: GpsStatus()),
    ),
    points: points,
  );
  await settle(tester);
  return location;
}

void main() {
  testWidgets('first launch: empty state and Save', (tester) async {
    await _pump(tester, FakePointsRepository());

    expect(find.text('Пока нет точек'), findsOneWidget);
    await tester.tap(find.text('Сохранить место'));
    await settle(tester);
    expect(find.text('route /points/new'), findsOneWidget);
  });

  testWidgets('points but none active: offers to choose one', (tester) async {
    await _pump(tester, FakePointsRepository([savedPoint('a', active: false)]));

    expect(find.text('Нет активных точек'), findsOneWidget);
    await tester.tap(find.text('Выбрать точку'));
    await settle(tester);
    expect(find.text('route /points'), findsOneWidget);
  });

  testWidgets('active points with distance, a tap navigates', (tester) async {
    final location = await _pump(
      tester,
      FakePointsRepository([savedPoint('a', name: 'Машина')]),
    );
    expect(find.text('Машина'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);

    location.fixes.add(Result.success(fixWithAccuracy(8)));
    await settle(tester);
    expect(find.text('—'), findsNothing);

    await tester.tap(find.text('Машина'));
    await settle(tester);
    expect(find.text('route /navigate/a'), findsOneWidget);
  });

  testWidgets('GPS state sits above the points', (tester) async {
    await _pump(tester, FakePointsRepository());
    expect(find.text('Доступ к геолокации'), findsOneWidget);
    expect(find.byType(GpsStatus), findsOneWidget);
    expect(find.byType(Column), findsWidgets);
  });

  group('long press on a card', () {
    final car = savedPoint('a', name: 'Машина');

    Future<void> openSheet(WidgetTester tester) async {
      await tester.longPress(find.text('Машина'));
      await settle(tester);
    }

    testWidgets('offers the actions and does not navigate', (tester) async {
      await _pump(tester, FakePointsRepository([car]));
      await openSheet(tester);

      for (final label in [
        'Подробнее',
        'Переименовать',
        'Сделать неактивной',
        'Удалить',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.textContaining('route'), findsNothing);
    });

    testWidgets('details opens the point', (tester) async {
      await _pump(tester, FakePointsRepository([car]));
      await openSheet(tester);

      await tester.tap(find.text('Подробнее'));
      await settle(tester);

      expect(find.text('route /points/a'), findsOneWidget);
    });

    testWidgets('rename asks for the name', (tester) async {
      final points = FakePointsRepository([car]);
      await _pump(tester, points);
      await openSheet(tester);

      await tester.tap(find.text('Переименовать'));
      await settle(tester);
      await tester.enterText(find.byType(EditableText), 'Гараж');
      await tester.tap(find.text('Сохранить').last);
      await settle(tester);

      expect(points.points.single.name, 'Гараж');
    });

    testWidgets('an empty name is refused and changes nothing', (tester) async {
      final points = FakePointsRepository([car]);
      await _pump(tester, points);
      await openSheet(tester);

      await tester.tap(find.text('Переименовать'));
      await settle(tester);
      await tester.enterText(find.byType(EditableText), '   ');
      await tester.tap(find.text('Сохранить').last);
      await settle(tester);

      expect(find.text('Введите название'), findsOneWidget);
      expect(points.points.single.name, 'Машина');
    });

    testWidgets('deactivating removes the card and can be undone', (
      tester,
    ) async {
      final points = FakePointsRepository([
        car,
        savedPoint('b', name: 'Лагерь'),
      ]);
      await _pump(tester, points);
      await openSheet(tester);

      await tester.tap(find.text('Сделать неактивной'));
      await settle(tester);

      expect(points.points.first.isActive, isFalse);
      expect(find.text('Машина'), findsNothing);
      expect(find.text('«Машина» убрана с главного'), findsOneWidget);

      await tester.tap(find.text('Вернуть'));
      await settle(tester);

      expect(points.points.first.isActive, isTrue);
      expect(find.text('Машина'), findsOneWidget);
    });

    testWidgets('delete confirms, then offers undo', (tester) async {
      final points = FakePointsRepository([car]);
      await _pump(tester, points);
      await openSheet(tester);

      await tester.tap(find.text('Удалить'));
      await settle(tester);
      expect(points.points, hasLength(1));
      await tester.tap(find.text('Удалить').last);
      await settle(tester);

      expect(points.points, isEmpty);
      expect(find.text('Точка «Машина» удалена'), findsOneWidget);
      await tester.tap(find.text('Вернуть'));
      await settle(tester);
      expect(points.points.single.id, 'a');
    });
  });
}
