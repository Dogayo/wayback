import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

Widget _host(Widget child) => MaterialApp(
  theme: WbTheme.light,
  home: Scaffold(body: SizedBox(width: 358, child: child)),
);

void main() {
  testWidgets('point card shows name, distance and the arrow', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        WbPointCard(
          title: 'Машина',
          distance: '640 м',
          typeIcon: Icons.directions_car_outlined,
          direction: const WbPointDirection(
            icon: Icons.directions_car_outlined,
            rotation: 90,
          ),
          onTap: () => taps++,
        ),
      ),
    );

    expect(find.text('Машина'), findsOneWidget);
    expect(find.text('640 м'), findsOneWidget);
    expect(find.bySemanticsLabel('Машина, 640 м'), findsOneWidget);

    final arrow = tester.widget<WbDirectionArrow>(
      find.byType(WbDirectionArrow),
    );
    expect(arrow.rotation, 90);

    await tester.tap(find.byType(WbPointCard));
    expect(taps, 1);
  });

  testWidgets('type icon fills the dial until the direction is known', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const WbPointCard(
          title: 'Лагерь',
          distance: '1,2 км',
          typeIcon: Icons.cabin_outlined,
        ),
      ),
    );

    expect(find.byType(WbDirectionArrow), findsNothing);
    expect(find.byIcon(Icons.cabin_outlined), findsNWidgets(2));
  });

  testWidgets('unreliable compass paints the arrow in warning and says so', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const WbPointCard(
          title: 'Лагерь',
          distance: '1,2 км',
          typeIcon: Icons.cabin_outlined,
          direction: WbPointDirection(
            icon: Icons.cabin_outlined,
            rotation: 0,
            tone: WbDirectionTone.unreliable,
            semanticLabel: 'Направление примерное',
          ),
        ),
      ),
    );

    final arrow = tester.widget<WbDirectionArrow>(
      find.byType(WbDirectionArrow),
    );
    expect(arrow.color, WbColors.light.warning);
    expect(
      find.bySemanticsLabel(
        RegExp('1,2 км.*Направление примерное', dotAll: true),
      ),
      findsOneWidget,
    );
    handle.dispose();
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
