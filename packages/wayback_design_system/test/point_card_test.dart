import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

Widget _host(Widget child) => MaterialApp(
  theme: WbTheme.light,
  home: Scaffold(body: SizedBox(width: 358, child: child)),
);

void main() {
  testWidgets('point card shows name, distance and a rotated arrow', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        WbPointCard(
          title: 'Машина',
          distance: '640 м',
          typeIcon: Icons.directions_car_outlined,
          rotation: 90,
          onTap: () => taps++,
        ),
      ),
    );

    expect(find.text('Машина'), findsOneWidget);
    expect(find.text('640 м'), findsOneWidget);
    expect(find.bySemanticsLabel('Машина, 640 м'), findsOneWidget);

    final arrow = tester.widget<Transform>(
      find.ancestor(
        of: find.byIcon(Icons.navigation),
        matching: find.byType(Transform),
      ),
    );
    final angle = math.atan2(
      arrow.transform.entry(1, 0),
      arrow.transform.entry(0, 0),
    );
    expect(angle, closeTo(math.pi / 2, 1e-6));

    await tester.tap(find.byType(WbPointCard));
    expect(taps, 1);
  });

  testWidgets('arrow is hidden until the direction is known', (tester) async {
    await tester.pumpWidget(
      _host(
        const WbPointCard(
          title: 'Лагерь',
          distance: '1,2 км',
          typeIcon: Icons.cabin_outlined,
        ),
      ),
    );

    expect(find.byIcon(Icons.navigation), findsNothing);
  });

  testWidgets('skeleton keeps the card height', (tester) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            WbPointCard(
              title: 'Машина',
              distance: '640 м',
              typeIcon: Icons.directions_car_outlined,
              rotation: 0,
            ),
            WbPointCardSkeleton(),
          ],
        ),
      ),
    );

    expect(find.byType(WbSkeleton), findsNWidgets(3));
    expect(
      tester.getSize(find.byType(WbPointCardSkeleton)).height,
      tester.getSize(find.byType(WbPointCard)).height,
    );
  });
}
