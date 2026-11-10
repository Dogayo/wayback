import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

Widget _host(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: WbTheme.light,
  builder: (context, _) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
    child: Scaffold(body: Center(child: child)),
  ),
);

Offset _shift(WidgetTester tester) =>
    tester.getCenter(find.byType(Icon)) -
    tester.getCenter(find.byType(WbAnimatedPointIcon));

void main() {
  testWidgets('rests in place until it is told to play', (tester) async {
    await tester.pumpWidget(
      _host(const WbAnimatedPointIcon(WbPointType.car, size: 24)),
    );

    expect(tester.hasRunningAnimations, isFalse);
    expect(_shift(tester), Offset.zero);
  });

  testWidgets('turning active plays the motion once', (tester) async {
    await tester.pumpWidget(
      _host(const WbAnimatedPointIcon(WbPointType.car, size: 24)),
    );
    await tester.pumpWidget(
      _host(const WbAnimatedPointIcon(WbPointType.car, size: 24, active: true)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));

    expect(_shift(tester).dx, lessThan(0));

    await tester.pumpAndSettle();
    expect(_shift(tester), Offset.zero);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('with animations off it is simply in place', (tester) async {
    await tester.pumpWidget(
      _host(
        const WbAnimatedPointIcon(
          WbPointType.generic,
          size: 24,
          playOnAppear: true,
        ),
        reduceMotion: true,
      ),
    );
    await tester.pump();

    expect(_shift(tester), Offset.zero);
    expect(tester.hasRunningAnimations, isFalse);
  });

  for (final type in WbPointType.values) {
    testWidgets('${type.name} ends at rest', (tester) async {
      await tester.pumpWidget(
        _host(WbAnimatedPointIcon(type, size: 24, playOnAppear: true)),
      );
      await tester.pumpAndSettle();

      expect(_shift(tester), Offset.zero);
    });
  }

  testWidgets('finding the direction plays once and stops', (tester) async {
    await tester.pumpWidget(_host(const WbDirectionFinding()));
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('a snackbar with an action still goes away', (tester) async {
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

    WbSnackbar.show(context, 'Saved', actionLabel: 'Edit', onAction: () {});
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);

    await tester.pump(WbMotion.undoWindow);
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsNothing);
  });
}
