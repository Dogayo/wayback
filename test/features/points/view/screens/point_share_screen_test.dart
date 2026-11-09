import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/error/failures.dart';
import 'package:wayback/core/utils/geo/geo_point.dart';
import 'package:wayback/features/points/domain/repositories/point_share_repository.dart';
import 'package:wayback/features/points/view/bloc/point_details_bloc.dart';
import 'package:wayback/features/points/view/bloc/share_point_bloc.dart';
import 'package:wayback/features/points/view/screens/point_share_screen.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

import '../../../location/fake_location_repository.dart';
import '../../fake_point_share_repository.dart';
import '../../fake_points_repository.dart';
import 'screen_host.dart';

Future<FakePointShareRepository> _pump(
  WidgetTester tester, {
  String id = 'a',
}) async {
  final share = FakePointShareRepository();
  final points = FakePointsRepository([
    savedPoint(
      'a',
      name: 'Машина',
      position: const GeoPoint(latitude: 56.50353, longitude: 85.03131),
    ),
  ]);
  await pumpScreen(
    tester,
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              PointDetailsBloc(points, FakeLocationRepository(), pointId: id)
                ..fetch(),
        ),
        BlocProvider(create: (_) => SharePointBloc(share)),
      ],
      child: const PointShareScreen(),
    ),
  );
  await settle(tester);
  return share;
}

void main() {
  testWidgets('shows the name and the coordinates', (tester) async {
    await _pump(tester);

    expect(find.text('Машина'), findsOneWidget);
    expect(find.text('56.50353, 85.03131'), findsOneWidget);
  });

  testWidgets('shows a QR of the link', (tester) async {
    await _pump(tester);

    final qr = tester.widget<WbQrCode>(find.byType(WbQrCode));
    expect(qr.data, startsWith('wayback://app/import?'));
    expect(qr.data, contains('lat=56.50353'));
    expect(
      find.text('Наведите камеру другого телефона на код'),
      findsOneWidget,
    );
  });

  testWidgets('nothing is sent until asked', (tester) async {
    final share = await _pump(tester);
    expect(share.shared, isEmpty);
  });

  testWidgets('Send hands over a readable message with the link', (
    tester,
  ) async {
    final share = await _pump(tester);

    await tester.tap(find.text('Отправить'));
    await settle(tester);

    final message = share.shared.single.split('\n');
    expect(message[0], 'Машина');
    expect(message[1], '56.50353, 85.03131');
    expect(message[2], startsWith('wayback://app/import?'));
  });

  testWidgets('a failed send says so', (tester) async {
    final share = await _pump(tester);
    share.failNext = const StorageFailure(
      code: PointShareErrorCodes.shareFailed,
    );

    await tester.tap(find.text('Отправить'));
    await settle(tester);

    expect(find.text('Не удалось поделиться точкой'), findsOneWidget);
  });

  testWidgets('Copy puts just the coordinates on the clipboard', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await _pump(tester);

    await tester.tap(find.text('Скопировать координаты'));
    await settle(tester);

    expect(copied, '56.50353, 85.03131');
    expect(find.text('Координаты скопированы'), findsOneWidget);
  });

  testWidgets('a point that is gone offers the way back', (tester) async {
    await _pump(tester, id: 'gone');

    expect(find.text('Точка не найдена'), findsOneWidget);
  });
}
