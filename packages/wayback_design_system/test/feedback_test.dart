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
}
