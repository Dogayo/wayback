import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

Widget _host(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? WbTheme.light,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  for (final (name, theme) in [
    ('light', WbTheme.light),
    ('dark', WbTheme.dark),
  ]) {
    testWidgets('every illustration paints in $name theme', (tester) async {
      for (final kind in WbIllustrationKind.values) {
        await tester.pumpWidget(
          _host(WbIllustration(kind, size: 120), theme: theme),
        );
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(WbIllustration)),
          const Size(120, 120),
        );
      }
    });
  }

  testWidgets('illustration is decorative for screen readers', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WbIllustration(WbIllustrationKind.trail),
            Text('Три простых шага'),
          ],
        ),
      ),
    );
    expect(find.bySemanticsLabel('Три простых шага'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(WbIllustration),
        matching: find.byWidgetPredicate((w) => w is Semantics),
      ),
      findsNothing,
    );
    semantics.dispose();
  });

  testWidgets('page dots mark the current page and read as a label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(const WbPageDots(count: 3, index: 1, semanticLabel: 'Шаг 2 из 3')),
    );
    await tester.pumpAndSettle();

    final widths = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .map((c) => c.constraints?.maxWidth)
        .toList();
    expect(widths, [8, 24, 8]);
    expect(find.bySemanticsLabel('Шаг 2 из 3'), findsOneWidget);
    semantics.dispose();
  });
}
