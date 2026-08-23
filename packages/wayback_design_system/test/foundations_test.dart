import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

void main() {
  test('spacing follows the 4pt grid', () {
    expect(WbSpacing.xxs, 4);
    expect(WbSpacing.screenPadding, WbSpacing.md);
    expect(WbSpacing.tapTarget, greaterThanOrEqualTo(44));
  });

  testWidgets('theme exposes semantic colors', (tester) async {
    late WbColors colors;
    await tester.pumpWidget(
      MaterialApp(
        theme: WbTheme.light,
        home: Builder(
          builder: (context) {
            colors = context.wbColors;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(colors.surfaceDefault, WbColors.light.surfaceDefault);
    expect(colors.actionPrimaryBg, WbColors.light.actionPrimaryBg);
  });

  testWidgets('button keeps a 44dp tap target', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: WbTheme.light,
        home: const Scaffold(
          body: WbButton(label: 'Сохранить', onPressed: _noop),
        ),
      ),
    );
    expect(tester.getSize(find.byType(TextButton)).height, 44);
  });
}

void _noop() {}
