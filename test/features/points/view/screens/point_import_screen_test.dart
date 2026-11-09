import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/points/domain/entities/point_draft.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/view/bloc/point_form_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_import_bloc.dart';
import 'package:wayback/features/points/view/bloc/save_point_bloc.dart';
import 'package:wayback/features/points/view/screens/point_import_screen.dart';

import '../../../location/fake_location_repository.dart';
import '../../fake_points_repository.dart';
import 'screen_host.dart';

Future<FakePointsRepository> _pump(
  WidgetTester tester, {
  String text = '',
  FakePointsRepository? repository,
}) async {
  final points = repository ?? FakePointsRepository();
  final draft = parsePointText(text);
  await pumpScreen(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PointFormBloc(
            points,
            labelOf: (type) => type.name,
            numbered: (label, number) => '$label $number',
            name: draft?.name,
            type: draft?.type ?? PointType.generic,
          )..add(const PointFormStarted()),
        ),
        BlocProvider(
          create: (_) =>
              PointImportBloc(points, FakeLocationRepository(), text: text)
                ..add(const PointImportStarted()),
        ),
        BlocProvider(create: (_) => SavePointBloc(points)),
      ],
      child: PointImportScreen(received: text.isNotEmpty),
    ),
  );
  await settle(tester);
  return points;
}

Finder _field(int index) => find.byType(EditableText).at(index);

String _value(WidgetTester tester, int index) =>
    tester.widget<EditableText>(_field(index)).controller.text;

void main() {
  testWidgets('saving text without coordinates shows the error', (
    tester,
  ) async {
    final points = await _pump(tester);

    await tester.enterText(_field(0), 'где-то у реки');
    await tester.tap(find.text('Сохранить'));
    await settle(tester);

    expect(find.text('Не удалось распознать координаты'), findsOneWidget);
    expect(points.points, isEmpty);
    expect(find.text('По координатам'), findsOneWidget);
  });

  testWidgets('typing takes the error away', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Сохранить'));
    await settle(tester);

    await tester.enterText(_field(0), '5');
    await settle(tester);

    expect(find.text('Не удалось распознать координаты'), findsNothing);
  });

  testWidgets('shows how it read the coordinates and saves them', (
    tester,
  ) async {
    final points = await _pump(tester);

    await tester.enterText(_field(0), '56.50353, 85.03131');
    await settle(tester);
    expect(find.text('Широта 56.50353, долгота 85.03131'), findsOneWidget);

    await tester.tap(find.text('Сохранить'));
    await settle(tester);

    final point = points.points.single;
    expect(point.position.latitude, 56.50353);
    expect(point.position.longitude, 85.03131);
    expect(point.isActive, isTrue);
    expect(find.text('route /'), findsOneWidget);
  });

  testWidgets('warns about rough coordinates but lets them through', (
    tester,
  ) async {
    final points = await _pump(tester);

    await tester.enterText(_field(0), '56.5, 85');
    await settle(tester);
    expect(find.text('Координаты неточные'), findsOneWidget);
    expect(find.text('Широта 56.5, долгота 85'), findsOneWidget);

    await tester.tap(find.text('Сохранить'));
    await settle(tester);
    expect(points.points, hasLength(1));
  });

  testWidgets('warns about a point already saved right there', (tester) async {
    await _pump(
      tester,
      repository: FakePointsRepository([
        savedPoint(
          'a',
          name: 'Машина',
          position: const GeoPoint(latitude: 56.50353, longitude: 85.03131),
        ),
      ]),
    );

    await tester.enterText(_field(0), '56.50355, 85.03131');
    await settle(tester);

    expect(find.text('Рядом уже есть «Машина»'), findsOneWidget);
  });

  testWidgets('a received link fills everything and waits for Save', (
    tester,
  ) async {
    final points = await _pump(
      tester,
      text: 'wayback://app/import?lat=56.50353&lon=85.03131&t=tent&n=Lager',
    );

    expect(points.points, isEmpty);
    expect(find.text('Новая точка'), findsOneWidget);
    expect(_value(tester, 0), '56.50353, 85.03131');
    expect(_value(tester, 1), 'Lager');

    await tester.tap(find.text('Сохранить'));
    await settle(tester);

    expect(points.points.single.name, 'Lager');
    expect(points.points.single.type, PointType.tent);
  });

  testWidgets('paste reads the clipboard only when asked', (tester) async {
    var reads = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method != 'Clipboard.getData') return null;
        reads++;
        return {'text': 'Лагерь\n56.50353, 85.03131'};
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _pump(tester);
    expect(reads, 0);

    await tester.tap(find.text('Вставить'));
    await settle(tester);

    expect(reads, 1);
    expect(find.text('Широта 56.50353, долгота 85.03131'), findsOneWidget);
    expect(_value(tester, 1), 'Лагерь');
  });
}
