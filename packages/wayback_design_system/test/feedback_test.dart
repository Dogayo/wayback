import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

Widget _host(Widget child) => MaterialApp(
  theme: WbTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('empty state shows its texts and action', (tester) async {
    await tester.pumpWidget(
      _host(
        WbEmptyState(
          icon: Icons.add_location_alt_outlined,
          title: 'Пока нет точек',
          message: 'Сохраните место',
          action: WbButton(label: 'Сохранить', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Пока нет точек'), findsOneWidget);
    expect(find.text('Сохраните место'), findsOneWidget);
    expect(find.text('Сохранить'), findsOneWidget);
  });

  testWidgets('prompt returns the trimmed text or null', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    var result = WbDialogs.prompt(
      context,
      title: 'Название точки',
      initialValue: 'Машина',
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Машина у леса  ');
    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();
    expect(await result, 'Машина у леса');

    result = WbDialogs.prompt(context, title: 'Название точки');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });

  testWidgets('snackbar shows a message and replaces the previous one', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    WbSnackbar.show(context, 'Первое');
    WbSnackbar.show(context, 'Точка сохранена');
    await tester.pumpAndSettle();

    expect(find.text('Точка сохранена'), findsOneWidget);
    expect(find.text('Первое'), findsNothing);
  });

  testWidgets('icon tile is a round tile of its token size', (tester) async {
    await tester.pumpWidget(
      _host(const Center(child: WbIconTile(icon: Icons.cabin))),
    );

    expect(find.byIcon(Icons.cabin), findsOneWidget);
    expect(
      tester.getSize(find.byType(WbIconTile)),
      const Size.square(WbIconTile.size),
    );
  });

  testWidgets('destructive confirm keeps cancel neutral', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );

    unawaited(
      WbDialogs.confirm(
        context,
        title: 'Удалить?',
        message: 'Точка пропадёт',
        confirmLabel: 'Удалить',
        destructive: true,
      ),
    );
    await tester.pumpAndSettle();

    final cancel = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Отмена'),
    );
    expect(
      cancel.style!.foregroundColor!.resolve({}),
      WbColors.light.contentPrimary,
    );
  });

  testWidgets('compact icon tile fits a list row', (tester) async {
    await tester.pumpWidget(
      _host(const Center(child: WbIconTile(icon: Icons.cabin, compact: true))),
    );

    expect(
      tester.getSize(find.byType(WbIconTile)),
      const Size.square(WbIconTile.compactSize),
    );
  });
}
