import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system_example/main.dart';

void main() {
  testWidgets('catalog renders at a mobile width without layout errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const WaybackDesignSystemDemo());
    await tester.pump();

    expect(find.text('Компоненты'), findsOneWidget);
    expect(find.text('Foundations'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sidebar button scrolls to the selected section', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const WaybackDesignSystemDemo());
    await tester.pump();

    final feedbackHeading = find.text('Feedback').last;
    expect(tester.getTopLeft(feedbackHeading).dy, greaterThan(800));

    await tester.tap(find.byKey(const ValueKey('sidebar-Feedback')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final headingY = tester.getTopLeft(feedbackHeading).dy;
    expect(headingY, inInclusiveRange(0, 800));
    expect(tester.takeException(), isNull);
  });
}
