import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// A navigator of [pages] the way a router builds one.
Widget _pages(List<Page<void>> pages, {bool reduceMotion = false}) =>
    MaterialApp(
      theme: WbTheme.light,
      // No home: the only navigator is the one under test.
      builder: (context, _) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: Navigator(pages: pages, onDidRemovePage: (_) {}),
      ),
    );

WbPage<void> _page(String name, [WbTransition t = WbTransition.drill]) =>
    WbPage(
      key: ValueKey(name),
      transition: t,
      child: Scaffold(body: Center(child: Text(name))),
    );

/// The opacity [label]'s screen is drawn with: its own fade, times the
/// share of it not yet covered by a veil.
double _opacity(WidgetTester tester, String label) {
  var opacity = 1.0;
  for (final fade in tester.widgetList<FadeTransition>(
    find.ancestor(of: find.text(label), matching: find.byType(FadeTransition)),
  )) {
    opacity *= fade.opacity.value;
  }
  return opacity;
}

void main() {
  group('WbMotion.of', () {
    testWidgets('keeps the duration normally', (tester) async {
      late Duration d;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            d = WbMotion.of(context, WbMotion.base);
            return const SizedBox();
          },
        ),
      );
      expect(d, WbMotion.base);
    });

    testWidgets('is zero when animations are removed', (tester) async {
      late Duration d;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              d = WbMotion.of(context, WbMotion.base);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(d, Duration.zero);
    });

    test('exit is shorter than enter', () {
      expect(WbMotion.slowExit, lessThan(WbMotion.slow));
    });
  });

  group('WbPage', () {
    testWidgets('drill fades and shifts the new screen in', (tester) async {
      await tester.pumpWidget(_pages([_page('A')]));
      await tester.pumpWidget(_pages([_page('A'), _page('B')]));

      // At 80 ms the new screen has not started to fade in yet.
      await tester.pump(const Duration(milliseconds: 80));
      expect(_opacity(tester, 'B'), 0);
      final center = tester.getCenter(find.byType(Navigator)).dx;
      expect(tester.getCenter(find.text('B')).dx, greaterThan(center));

      await tester.pumpAndSettle();
      expect(_opacity(tester, 'B'), 1);
      expect(tester.getCenter(find.text('B')).dx, center);
      expect(find.text('A'), findsNothing);
    });

    testWidgets('the screen below leaves slowly at first', (tester) async {
      await tester.pumpWidget(_pages([_page('A')]));
      await tester.pumpWidget(_pages([_page('A'), _page('B')]));
      await tester.pump();
      // Halfway through its 110 ms: an accelerating fade is still shy.
      await tester.pump(const Duration(milliseconds: 55));

      final veil = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.byWidgetPredicate(
                (w) =>
                    w is ColoredBox && w.color == WbColors.light.surfaceDefault,
              ),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(veil.opacity.value, inExclusiveRange(0, .5));
    });

    testWidgets('drill takes slow to open and slowExit to close', (
      tester,
    ) async {
      await tester.pumpWidget(_pages([_page('A')]));
      await tester.pumpWidget(_pages([_page('A'), _page('B')]));
      await tester.pump();
      await tester.pump(WbMotion.slow - const Duration(milliseconds: 20));
      expect(_opacity(tester, 'B'), lessThan(1));
      await tester.pump(const Duration(milliseconds: 20));
      expect(_opacity(tester, 'B'), 1);

      await tester.pumpWidget(_pages([_page('A')]));
      await tester.pump();
      await tester.pump(WbMotion.slowExit - const Duration(milliseconds: 20));
      expect(find.text('B'), findsOneWidget);
      // One more frame lets the navigator drop the finished route.
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.text('B'), findsNothing);
    });

    testWidgets('modal slides up and leaves the screen below in place', (
      tester,
    ) async {
      await tester.pumpWidget(_pages([_page('A')]));
      final below = tester.getTopLeft(find.text('A'));
      await tester.pumpWidget(
        _pages([_page('A'), _page('B', WbTransition.modal)]),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));

      expect(tester.getTopLeft(find.text('A')), below);
      expect(tester.getTopLeft(find.text('B')).dy, greaterThan(below.dy));
      expect(_opacity(tester, 'B'), 1);
    });

    testWidgets('enter mode grows the new screen from 0.92', (tester) async {
      await tester.pumpWidget(_pages([_page('A')]));
      await tester.pumpWidget(
        _pages([_page('A'), _page('B', WbTransition.enterMode)]),
      );
      await tester.pump();

      final scale = tester.widget<ScaleTransition>(
        find
            .ancestor(
              of: find.text('B'),
              matching: find.byType(ScaleTransition),
            )
            .first,
      );
      expect(scale.scale.value, closeTo(.92, .001));
    });

    testWidgets('screens switch at once when animations are removed', (
      tester,
    ) async {
      await tester.pumpWidget(_pages([_page('A')], reduceMotion: true));
      await tester.pumpWidget(
        _pages([_page('A'), _page('B')], reduceMotion: true),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('iOS keeps the Cupertino transition for a drill', (
      tester,
    ) async {
      await tester.pumpWidget(_pages([_page('A')]));
      await tester.pumpWidget(_pages([_page('A'), _page('B')]));
      await tester.pump();

      expect(
        find.ancestor(
          of: find.text('B'),
          matching: find.byType(CupertinoPageTransition),
        ),
        findsOneWidget,
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));
  });

  group('WbStateSwitcher', () {
    Widget host(Object state, {bool animateSize = false}) => MaterialApp(
      home: Scaffold(
        body: WbStateSwitcher(
          state: state,
          animateSize: animateSize,
          child: Text('$state', key: ValueKey('text-$state')),
        ),
      ),
    );

    testWidgets('crossfades when the state changes', (tester) async {
      await tester.pumpWidget(host('loading'));
      await tester.pumpWidget(host('content'));
      await tester.pump(const Duration(milliseconds: 110));

      expect(find.text('loading'), findsOneWidget);
      expect(find.text('content'), findsOneWidget);
      expect(_opacity(tester, 'loading'), 0);
      expect(_opacity(tester, 'content'), inExclusiveRange(0, 1));

      await tester.pumpAndSettle();
      expect(find.text('loading'), findsNothing);
      expect(_opacity(tester, 'content'), 1);
    });

    testWidgets('new data in the same state does not fade', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WbStateSwitcher(state: 'content', child: Text('1 m')),
        ),
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: WbStateSwitcher(state: 'content', child: Text('2 m')),
        ),
      );
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.text('2 m'), findsOneWidget);
    });

    testWidgets('animateSize grows to the new child', (tester) async {
      Widget sized(double height) => MaterialApp(
        home: Align(
          alignment: Alignment.topCenter,
          child: WbStateSwitcher(
            state: height,
            animateSize: true,
            child: SizedBox(width: 100, height: height),
          ),
        ),
      );
      await tester.pumpWidget(sized(20));
      await tester.pumpWidget(sized(100));
      await tester.pump(WbMotion.base ~/ 2);
      final halfway = tester.getSize(find.byType(AnimatedSize)).height;
      expect(halfway, inExclusiveRange(20, 100));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(AnimatedSize)).height, 100);
    });
  });

  group('WbButton loading', () {
    Widget host({required bool loading}) => MaterialApp(
      theme: WbTheme.light,
      home: Scaffold(
        body: Center(
          child: WbButton(
            label: 'Сохранить',
            loading: loading,
            onPressed: () {},
          ),
        ),
      ),
    );

    testWidgets('keeps its width while loading', (tester) async {
      await tester.pumpWidget(host(loading: false));
      final idle = tester.getSize(find.byType(WbButton));
      await tester.pumpWidget(host(loading: true));
      await tester.pump(WbMotion.fast);
      expect(tester.getSize(find.byType(WbButton)), idle);
    });

    testWidgets('fades the label out and the spinner in', (tester) async {
      await tester.pumpWidget(host(loading: false));
      await tester.pumpWidget(host(loading: true));
      await tester.pump(WbMotion.fast);

      expect(_opacity(tester, 'Сохранить'), 0);
      final spinner = find.byType(CircularProgressIndicator);
      var shown = 1.0;
      for (final fade in tester.widgetList<FadeTransition>(
        find.ancestor(of: spinner, matching: find.byType(FadeTransition)),
      )) {
        shown *= fade.opacity.value;
      }
      expect(shown, 1);
    });
  });
}
