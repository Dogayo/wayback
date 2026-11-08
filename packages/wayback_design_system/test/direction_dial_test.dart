import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

Widget _host(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? WbTheme.light,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('the dial reads out the label it is given', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(const WbDirectionDial(rotation: 35, semanticLabel: 'To the car')),
    );

    expect(find.bySemanticsLabel('To the car'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('searching stops when animations are off', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _host(const WbDirectionSearching()),
      ),
    );

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('distance splits the unit off the number', (tester) async {
    await tester.pumpWidget(_host(const WbDistanceValue('645 м')));

    final text = tester.widget<Text>(find.byType(Text));
    final spans = (text.textSpan! as TextSpan).children!.cast<TextSpan>();
    expect(spans.map((span) => span.text), ['645', ' м']);
    expect(find.text('645 м'), findsOneWidget);
  });

  testWidgets('distance without a unit stays whole', (tester) async {
    await tester.pumpWidget(_host(const WbDistanceValue('—')));

    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('arrival is muted in the dark theme', (tester) async {
    late WbArrivalColors light;
    late WbArrivalColors dark;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) {
            light = context.wbArrivalColors;
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpWidget(
      _host(
        theme: WbTheme.dark,
        Builder(
          builder: (context) {
            dark = context.wbArrivalColors;
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(light.background, WbColors.light.positive);
    expect(dark.background, WbColors.dark.positiveBg);
  });

  testWidgets('alert row joins title and message', (tester) async {
    await tester.pumpWidget(
      _host(
        const WbAlertRow(
          title: 'Компас неточен',
          message: 'поводите восьмёркой',
          tone: WbTone.warning,
        ),
      ),
    );

    expect(find.text('Компас неточен: поводите восьмёркой'), findsOneWidget);
  });
}
