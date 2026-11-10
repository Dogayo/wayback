import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_access.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/location/view/bloc/location_fix_bloc.dart';
import 'package:wayback/features/location/view/bloc/open_location_settings_bloc.dart';
import 'package:wayback/features/location/view/bloc/request_location_permission_bloc.dart';
import 'package:wayback/features/location/view/widgets/gps_status.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/view/bloc/delete_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/edit_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/home_bloc.dart';
import 'package:wayback/features/points/view/bloc/quick_save_point_bloc.dart';
import 'package:wayback/features/points/view/bloc/set_point_active_bloc.dart';
import 'package:wayback/features/points/view/screens/home_screen.dart';
import 'package:wayback/features/points/view/widgets/point_edit_form.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

import '../../../location/fake_location_repository.dart';
import '../../fake_points_repository.dart';
import 'screen_host.dart';

Future<FakeLocationRepository> _pump(
  WidgetTester tester,
  FakePointsRepository points, {
  List<WbHaptic>? haptics,
  Result<LocationFix>? fix = const Result.failure(
    StorageFailure(code: LocationErrorCodes.permissionDenied),
  ),
  PointDirectionBuilder? largeDirection,
}) async {
  final location = FakeLocationRepository(
    access: const Result.success(LocationAccess.denied),
  )..nextFix = fix;
  await pumpScreen(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocationFixBloc(location)..fetch()),
        BlocProvider(create: (_) => RequestLocationPermissionBloc(location)),
        BlocProvider(create: (_) => OpenLocationSettingsBloc(location)),
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
      ],
      child: HomeScreen(
        gpsStatus: const GpsStatus(),
        largeDirection: largeDirection,
      ),
    ),
    points: points,
    haptics: haptics,
  );
  await settle(tester);
  return location;
}

void main() {
  group('saving in one tap', () {
    testWidgets('a good fix saves and offers to edit', (tester) async {
      final points = FakePointsRepository();
      final haptics = <WbHaptic>[];
      await _pump(
        tester,
        points,
        haptics: haptics,
        fix: Result.success(fixWithAccuracy(8)),
      );

      await tester.tap(find.text('Сохранить место'));
      await settle(tester);

      expect(points.points.single.name, 'Точка');
      expect(points.points.single.type, PointType.generic);
      expect(find.text('Точка сохранена'), findsOneWidget);
      expect(find.text('Изменить'), findsOneWidget);
      expect(find.text('Вернуть'), findsNothing);
      expect(haptics, contains(WbHaptic.success));
      expect(find.text('route /points/new'), findsNothing);
    });

    testWidgets('a taken name gets a number', (tester) async {
      final points = FakePointsRepository([savedPoint('a', name: 'Точка')]);
      await _pump(tester, points, fix: Result.success(fixWithAccuracy(8)));

      await tester.tap(find.text('Сохранить место'));
      await settle(tester);

      expect(points.points.map((p) => p.name), contains('Точка 2'));
    });

    testWidgets('a weak fix goes to the form, nothing saved', (tester) async {
      final points = FakePointsRepository();
      await _pump(tester, points, fix: Result.success(fixWithAccuracy(500)));

      await tester.tap(find.text('Сохранить место'));
      await settle(tester);

      expect(points.points, isEmpty);
      expect(find.text('route /points/new'), findsOneWidget);
    });

    testWidgets('Edit changes the name and type in a sheet', (tester) async {
      final points = FakePointsRepository();
      await _pump(tester, points, fix: Result.success(fixWithAccuracy(8)));
      await tester.tap(find.text('Сохранить место'));
      await settle(tester);

      await tester.tap(find.text('Изменить'));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'Машина у леса');
      await tester.tap(find.byKey(const ValueKey('wb-type-car')));
      await settle(tester);
      await tester.tap(find.text('Сохранить'));
      await settle(tester);

      expect(points.points.single.name, 'Машина у леса');
      expect(points.points.single.type, PointType.car);
    });

    testWidgets('an empty name stays in the sheet', (tester) async {
      final points = FakePointsRepository();
      await _pump(tester, points, fix: Result.success(fixWithAccuracy(8)));
      await tester.tap(find.text('Сохранить место'));
      await settle(tester);
      await tester.tap(find.text('Изменить'));
      await settle(tester);

      await tester.enterText(find.byType(TextField), '  ');
      await tester.tap(find.text('Сохранить'));
      await settle(tester);

      expect(find.byType(PointEditForm), findsOneWidget);
      expect(points.points.single.name, 'Точка');
    });
  });

  group('one point alone', () {
    Widget dial(String id, IconData icon) => const Text('full dial');

    testWidgets('gets the large card', (tester) async {
      await _pump(
        tester,
        FakePointsRepository([savedPoint('a', name: 'Домик')]),
        largeDirection: dial,
      );

      expect(find.byType(WbPointHeroCard), findsOneWidget);
      expect(find.text('full dial'), findsOneWidget);
      expect(find.byType(WbPointCard), findsNothing);

      await tester.tap(find.text('Домик'));
      await settle(tester);
      expect(find.text('route /navigate/a'), findsOneWidget);
    });

    testWidgets('two points keep the ordinary cards', (tester) async {
      await _pump(
        tester,
        FakePointsRepository([savedPoint('a'), savedPoint('b')]),
        largeDirection: dial,
      );

      expect(find.byType(WbPointHeroCard), findsNothing);
      expect(find.byType(WbPointCard), findsNWidgets(2));
    });
  });

  testWidgets('first launch: empty state and Save', (tester) async {
    await _pump(tester, FakePointsRepository());

    expect(find.text('Пока нет точек'), findsOneWidget);
    await tester.tap(find.text('Сохранить место'));
    await settle(tester);
    expect(find.text('route /points/new'), findsOneWidget);
  });

  testWidgets('points but none active: offers to choose one', (tester) async {
    await _pump(tester, FakePointsRepository([savedPoint('a', active: false)]));

    expect(find.text('На главной пока пусто'), findsOneWidget);
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
        'Изменить',
        'Убрать с главной',
        'Удалить',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.textContaining('route'), findsNothing);
    });

    testWidgets('answers the press', (tester) async {
      final haptics = <WbHaptic>[];
      await _pump(tester, FakePointsRepository([car]), haptics: haptics);

      await openSheet(tester);

      expect(haptics, [WbHaptic.press]);
    });

    testWidgets('deleting answers once it is done', (tester) async {
      final haptics = <WbHaptic>[];
      await _pump(tester, FakePointsRepository([car]), haptics: haptics);
      await openSheet(tester);
      await tester.tap(find.text('Удалить'));
      await settle(tester);
      expect(haptics, [WbHaptic.press], reason: 'not before confirming');

      await tester.tap(find.text('Удалить').last);
      await settle(tester);

      expect(haptics, [WbHaptic.press, WbHaptic.press]);
      await expireUndo(tester);
    });

    testWidgets('share opens the share screen', (tester) async {
      await _pump(tester, FakePointsRepository([car]));
      await openSheet(tester);

      await tester.tap(find.text('Поделиться'));
      await settle(tester);

      expect(find.text('route /points/a/share'), findsOneWidget);
    });

    testWidgets('details opens the point', (tester) async {
      await _pump(tester, FakePointsRepository([car]));
      await openSheet(tester);

      await tester.tap(find.text('Подробнее'));
      await settle(tester);

      expect(find.text('route /points/a'), findsOneWidget);
    });

    testWidgets('edit opens the sheet with the name', (tester) async {
      final points = FakePointsRepository([car]);
      await _pump(tester, points);
      await openSheet(tester);

      await tester.tap(find.text('Изменить'));
      await settle(tester);
      await tester.enterText(find.byType(EditableText), 'Гараж');
      await tester.tap(find.text('Сохранить').last);
      await settle(tester);

      expect(points.points.single.name, 'Гараж');
    });

    testWidgets('edit changes the type of a saved point', (tester) async {
      final points = FakePointsRepository([car]);
      await _pump(tester, points);
      await openSheet(tester);

      await tester.tap(find.text('Изменить'));
      await settle(tester);
      await tester.tap(find.text('Рыбалка'));
      await settle(tester);
      await tester.tap(find.text('Сохранить').last);
      await settle(tester);

      expect(points.points.single.type, PointType.fishing);
    });

    testWidgets('an empty name is refused and changes nothing', (tester) async {
      final points = FakePointsRepository([car]);
      await _pump(tester, points);
      await openSheet(tester);

      await tester.tap(find.text('Изменить'));
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

      await tester.tap(find.text('Убрать с главной'));
      await settle(tester);

      expect(points.points.first.isActive, isFalse);
      expect(find.text('Машина'), findsNothing);
      expect(find.text('«Машина» убрана с главной'), findsOneWidget);

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
