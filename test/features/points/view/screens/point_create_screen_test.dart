import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/location/domain/entities/location_fix.dart';
import 'package:wayback/features/location/domain/repositories/location_repository.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/view/bloc/open_fix_settings_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_fix_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_form_bloc.dart';
import 'package:wayback/features/points/view/bloc/save_point_bloc.dart';
import 'package:wayback/features/points/view/screens/point_create_screen.dart';

import '../../../location/fake_location_repository.dart';
import '../../fake_points_repository.dart';
import 'screen_host.dart';

final class _LocationOff extends FakeLocationRepository {
  @override
  Future<Result<LocationFix>> currentFix() async => const Result.failure(
    SensorFailure(code: LocationErrorCodes.serviceDisabled),
  );
}

Future<FakePointsRepository> _pump(
  WidgetTester tester, {
  FakeLocationRepository? location,
}) async {
  final points = FakePointsRepository();
  final place = location ?? FakeLocationRepository();
  await pumpScreen(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PointFormBloc(
            points,
            labelOf: (type) => switch (type) {
              PointType.car => 'Машина',
              PointType.generic => 'Точка',
              _ => type.name,
            },
            numbered: (label, number) => '$label $number',
          )..add(const PointFormStarted()),
        ),
        BlocProvider(create: (_) => PointFixBloc(place)..fetch()),
        BlocProvider(create: (_) => SavePointBloc(points)),
        BlocProvider(create: (_) => OpenFixSettingsBloc(place)),
      ],
      child: const PointCreateScreen(),
    ),
  );
  await settle(tester);
  return points;
}

void main() {
  testWidgets('the name follows the type; saving goes back', (tester) async {
    final points = await _pump(tester);
    expect(find.text('Точка'), findsWidgets);
    expect(find.text('55.75580, 37.61730'), findsOneWidget);

    await tester.tap(find.text('Машина'));
    await settle(tester);
    await tester.tap(find.text('Сохранить'));
    await settle(tester);

    expect(points.points.single.name, 'Машина');
    expect(find.text('Точка «Машина» сохранена'), findsOneWidget);
    expect(find.text('route /'), findsOneWidget);
  });

  testWidgets('location off: no Save, settings offered', (tester) async {
    final location = _LocationOff();
    final points = await _pump(tester, location: location);

    expect(find.text('Геолокация выключена'), findsOneWidget);
    await tester.tap(find.text('Сохранить'));
    await settle(tester);
    expect(points.points, isEmpty);

    await tester.tap(find.text('Открыть настройки'));
    await settle(tester);
    expect(location.opened, ['location']);
  });
}
