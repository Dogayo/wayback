import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

void main() {
  testWidgets('type picker is a square 4 by 2 grid with a brand selection', (
    tester,
  ) async {
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
    expect(decoration.color, WbColors.light.brand600);
  });
}
