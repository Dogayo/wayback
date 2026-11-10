import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('distance draws only the number in Barlow', (tester) async {
    await tester.pumpWidget(_host(const WbDistanceValue('645 м')));

    final text = tester.widget<Text>(find.byType(Text));
    final spans = (text.textSpan! as TextSpan).children!.cast<TextSpan>();
    expect(spans.first.style, WbTypography.distanceNumber);
    expect(spans.last.style?.fontFamily, isNot(contains('Barlow')));
    expect(
      (text.textSpan! as TextSpan).style?.fontFamily,
      isNot(contains('Barlow')),
    );
  });

  testWidgets('Barlow digits keep one width', (tester) async {
    final bytes = File('assets/fonts/Barlow-SemiBold.ttf').readAsBytesSync();
    await tester.runAsync(() async {
      final loader = FontLoader(WbTypography.distanceNumber.fontFamily!)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    });

    double width(String digits) {
      final painter = TextPainter(
        text: TextSpan(
          text: digits,
          style: WbTypography.distanceNumber.copyWith(
            fontSize: 88,
            fontFeatures: WbTypography.tabularFigures,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      addTearDown(painter.dispose);
      return painter.width;
    }

    expect(width('111'), width('000'));
    expect(width('111'), greaterThan(100));
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

  test('positive meets AA for white text on it', () {
    final luminance = WbColors.light.positive.computeLuminance();
    expect(1.05 / (luminance + .05), greaterThanOrEqualTo(4.5));
  });
}
