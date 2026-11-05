import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

void main() {
  testWidgets(
    'type picker is a square 4 by 2 grid with an action-colored selection',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: WbTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: WbTypePicker(value: WbPointType.car, onChanged: (_) {}),
            ),
          ),
        ),
      );

      final car = find.byKey(const ValueKey('wb-type-car'));
      final tent = find.byKey(const ValueKey('wb-type-tent'));
      final house = find.byKey(const ValueKey('wb-type-house'));

      expect(tester.getSize(car).aspectRatio, closeTo(1, .001));
      expect(tester.getTopLeft(car).dy, tester.getTopLeft(tent).dy);
      expect(tester.getTopLeft(car).dx, tester.getTopLeft(house).dx);

      final selectedContainer = tester.widget<AnimatedContainer>(
        find.descendant(of: car, matching: find.byType(AnimatedContainer)),
      );
      final decoration = selectedContainer.decoration! as BoxDecoration;
      expect(decoration.color, WbColors.light.actionPrimaryBg);
    },
  );

  testWidgets('labels can be localized by the app', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: WbTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: WbTypePicker(
              value: WbPointType.car,
              onChanged: (_) {},
              labelOf: (type) => type == WbPointType.car ? 'Car' : type.name,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Car'), findsOneWidget);
    expect(find.text('Машина'), findsNothing);
    final semantics = tester.widget<Semantics>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('wb-type-car')),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(semantics.properties.label, 'Car');
  });

  test(
    'selected tile keeps text contrast of at least 4.5:1 in both themes',
    () {
      double contrast(Color a, Color b) {
        final la = a.computeLuminance(), lb = b.computeLuminance();
        return (math.max(la, lb) + .05) / (math.min(la, lb) + .05);
      }

      for (final colors in [WbColors.light, WbColors.dark]) {
        expect(
          contrast(colors.actionPrimaryFg, colors.actionPrimaryBg),
          greaterThanOrEqualTo(4.5),
        );
      }
    },
  );
}
