import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/features/points/view/bloc/points_list_bloc.dart';
import 'package:wayback/features/points/view/screens/points_list_screen.dart';

import '../../../location/fake_location_repository.dart';
import '../../fake_points_repository.dart';
import 'screen_host.dart';

Future<void> _pump(WidgetTester tester, FakePointsRepository points) async {
  await pumpScreen(
    tester,
    BlocProvider(
      create: (_) => PointsListBloc(points, FakeLocationRepository())..fetch(),
      child: const PointsListScreen(),
    ),
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
}
