import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

Future<SystemUiOverlayStyle> _styleOver(
  WidgetTester tester,
  Color background,
) async {
  await tester.pumpWidget(
    WbSystemBars(background: background, child: const SizedBox()),
  );
  return tester
      .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      )
      .value;
}

void main() {
  testWidgets('bars are transparent with icons that read on the background', (
    tester,
  ) async {
    final light = await _styleOver(tester, WbColors.light.surfaceDefault);
    expect(light.systemNavigationBarColor, Colors.transparent);
    expect(light.systemNavigationBarIconBrightness, Brightness.dark);

    final field = await _styleOver(tester, WbColors.light.positive);
    expect(field.systemNavigationBarIconBrightness, Brightness.light);
    expect(field.statusBarIconBrightness, Brightness.light);
  });

  testWidgets('a title starts right after the back button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: WbTheme.light,
        home: Scaffold(
          appBar: WbAppBar(title: 'Точка', onBack: () {}),
        ),
      ),
    );

    expect(tester.getTopLeft(find.text('Точка')).dx, 56);
  });

  testWidgets('scroll padding ends clear of the navigation bar', (
    tester,
  ) async {
    late EdgeInsets padding;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.only(bottom: 24)),
        child: Builder(
          builder: (context) {
            padding = context.wbScrollPadding;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(padding.top, WbSpacing.screenPadding);
    expect(padding.bottom, WbSpacing.screenPadding + 24);
  });
}
