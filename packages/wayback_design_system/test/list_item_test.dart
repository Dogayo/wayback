import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

Widget _host(Widget child) => MaterialApp(
  theme: WbTheme.light,
  home: Scaffold(body: Column(children: [child])),
);

void main() {
  testWidgets('a row is 56 dp tall, 72 dp with a subtitle', (tester) async {
    await tester.pumpWidget(_host(const WbListItem(title: 'Русский')));
    expect(tester.getSize(find.byType(WbListItem)).height, 56);

    await tester.pumpWidget(
      _host(const WbListItem(title: 'Вид вибрации', subtitle: 'Обычная')),
    );
    expect(tester.getSize(find.byType(WbListItem)).height, 72);
  });

  testWidgets('text starts 16 dp from the edge', (tester) async {
    await tester.pumpWidget(_host(const WbListItem(title: 'Русский')));

    expect(tester.getTopLeft(find.text('Русский')).dx, 16);
  });

  testWidgets('a chosen option carries a brand check', (tester) async {
    await tester.pumpWidget(
      _host(const WbListItem(title: 'Как в системе', selected: true)),
    );

    final check = tester.widget<Icon>(find.byIcon(Icons.check));
    expect(check.color, WbColors.light.brand600);
  });
}
