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
    await _pumpDesktop(tester);

    // Sections build lazily: the heading is not there until it is near.
    expect(find.text('Feedback'), findsOneWidget);

    await _goTo(tester, 'Feedback');

    expect(_headingY(tester, 'Feedback'), inInclusiveRange(0, 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sidebar reaches the last section and comes back', (
    tester,
  ) async {
    await _pumpDesktop(tester);

    await _goTo(tester, 'Motion');
    expect(_headingY(tester, 'Motion'), inInclusiveRange(0, 800));

    await _goTo(tester, 'Foundations');
    expect(_headingY(tester, 'Foundations'), inInclusiveRange(0, 800));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpDesktop(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const WaybackDesignSystemDemo());
  await tester.pump();
}

/// Taps the sidebar button and lets the stepped scroll finish. Spinners in
/// the catalog never settle, so frames are pumped for a fixed time.
Future<void> _goTo(WidgetTester tester, String section) async {
  await tester.tap(find.byKey(ValueKey('sidebar-$section')));
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The section heading is the last match: the first is the sidebar button.
double _headingY(WidgetTester tester, String section) {
  final headings = find.text(section);
  expect(headings, findsNWidgets(2));
  return tester.getTopLeft(headings.last).dy;
}
