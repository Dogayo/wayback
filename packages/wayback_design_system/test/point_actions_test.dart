import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

Widget _host(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: WbTheme.light,
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(390, 844),
      disableAnimations: reduceMotion,
    ),
    child: Scaffold(body: child),
  ),
);

void main() {
  group('WbSwipeActions', () {
    Widget rows(void Function(String) pressed) => ListView(
      children: [
        for (final name in ['A', 'B'])
          WbSwipeActions(
            actions: [
              WbSwipeAction(
                icon: Icons.edit,
                label: 'edit $name',
                onPressed: () => pressed(name),
              ),
              WbSwipeAction(
                icon: Icons.delete,
                label: 'delete $name',
                destructive: true,
                onPressed: () {},
              ),
            ],
            child: SizedBox(height: 72, child: Center(child: Text(name))),
          ),
      ],
    );

    testWidgets('closed, it shows no actions', (tester) async {
      await tester.pumpWidget(_host(rows((_) {})));
      expect(find.text('edit A'), findsNothing);
    });

    testWidgets('past 40% it stays open at the width of the panel', (
      tester,
    ) async {
      await tester.pumpWidget(_host(rows((_) {})));
      final start = tester.getCenter(find.text('A')).dx;

      await tester.timedDrag(
        find.text('A'),
        const Offset(-90, 0),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();

      expect(tester.getCenter(find.text('A')).dx, start - 176);
      expect(find.text('edit A'), findsOneWidget);
    });

    testWidgets('short of 40% it closes', (tester) async {
      await tester.pumpWidget(_host(rows((_) {})));
      final start = tester.getCenter(find.text('A')).dx;

      await tester.timedDrag(
        find.text('A'),
        const Offset(-50, 0),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();

      expect(tester.getCenter(find.text('A')).dx, start);
      expect(find.text('edit A'), findsNothing);
    });

    testWidgets('a flick opens it whatever the distance', (tester) async {
      await tester.pumpWidget(_host(rows((_) {})));

      await tester.fling(find.text('A'), const Offset(-60, 0), 1500);
      await tester.pumpAndSettle();

      expect(find.text('edit A'), findsOneWidget);
    });

    testWidgets('a swipe the other way does nothing', (tester) async {
      await tester.pumpWidget(_host(rows((_) {})));
      final start = tester.getCenter(find.text('A')).dx;

      await tester.drag(find.text('A'), const Offset(200, 0));
      await tester.pumpAndSettle();

      expect(tester.getCenter(find.text('A')).dx, start);
    });

    testWidgets('an action runs and the row closes', (tester) async {
      final pressed = <String>[];
      await tester.pumpWidget(_host(rows(pressed.add)));
      await tester.drag(find.text('A'), const Offset(-200, 0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('edit A'));
      await tester.pumpAndSettle();

      expect(pressed, ['A']);
      expect(find.text('edit A'), findsNothing);
    });

    testWidgets('opening another row closes the first', (tester) async {
      await tester.pumpWidget(_host(rows((_) {})));
      await tester.drag(find.text('A'), const Offset(-200, 0));
      await tester.pumpAndSettle();

      await tester.drag(find.text('B'), const Offset(-200, 0));
      await tester.pumpAndSettle();

      expect(find.text('edit A'), findsNothing);
      expect(find.text('edit B'), findsOneWidget);
    });

    testWidgets('a tap on the open row closes it and goes no further', (
      tester,
    ) async {
      var tapped = 0;
      await tester.pumpWidget(
        _host(
          WbSwipeActions(
            actions: [
              WbSwipeAction(icon: Icons.edit, label: 'edit', onPressed: () {}),
            ],
            child: WbListItem(title: 'row', onTap: () => tapped++),
          ),
        ),
      );
      await tester.drag(find.text('row'), const Offset(-120, 0));
      await tester.pumpAndSettle();

      // The label has slid away to the left: tap what is left of the row.
      await tester.tapAt(
        Offset(200, tester.getCenter(find.byType(WbListItem)).dy),
      );
      await tester.pumpAndSettle();

      expect(tapped, 0);
      expect(find.text('edit'), findsNothing);
    });
  });

  group('WbAnimatedItems', () {
    Widget list(List<String> items, {bool reduceMotion = false}) => _host(
      WbAnimatedItems<String>(
        items: items,
        keyOf: (item) => item,
        itemBuilder: (_, item, isLast) =>
            SizedBox(height: 50, child: Text('$item${isLast ? ' last' : ''}')),
      ),
      reduceMotion: reduceMotion,
    );

    testWidgets('the first build does not animate', (tester) async {
      await tester.pumpWidget(list(['a', 'b']));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('a row that left folds away in its place', (tester) async {
      await tester.pumpWidget(list(['a', 'b', 'c']));
      await tester.pumpWidget(list(['a', 'c']));
      await tester.pump(WbMotion.base ~/ 2);

      final middle = tester.getTopLeft(find.text('b')).dy;
      expect(middle, tester.getBottomLeft(find.text('a')).dy);
      final next = tester.getTopLeft(find.text('c last')).dy;
      expect(next, inExclusiveRange(50, 100));

      await tester.pumpAndSettle();
      expect(find.text('b'), findsNothing);
      expect(tester.getTopLeft(find.text('c last')).dy, 50);
    });

    testWidgets('a new row unfolds', (tester) async {
      await tester.pumpWidget(list(['a']));
      await tester.pumpWidget(list(['a', 'b']));
      await tester.pump(WbMotion.base ~/ 2);

      expect(
        tester.getSize(find.byType(SizeTransition).last).height,
        lessThan(50),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(SizeTransition).last).height, 50);
    });

    testWidgets('a row that comes back midway stays', (tester) async {
      await tester.pumpWidget(list(['a', 'b']));
      await tester.pumpWidget(list(['b']));
      await tester.pump(WbMotion.base ~/ 2);
      await tester.pumpWidget(list(['a', 'b']));
      await tester.pumpAndSettle();

      expect(find.text('a'), findsOneWidget);
      expect(tester.getTopLeft(find.text('b last')).dy, 50);
    });

    testWidgets('rows go at once when animations are removed', (tester) async {
      await tester.pumpWidget(list(['a', 'b'], reduceMotion: true));
      await tester.pumpWidget(list(['b'], reduceMotion: true));
      await tester.pump();

      expect(find.text('a'), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('WbActionSheet', () {
    Widget opener(List<WbSheetAction> actions) => Builder(
      builder: (context) => TextButton(
        onPressed: () => WbActionSheet.show(
          context,
          title: 'Машина',
          subtitle: '640 м',
          icon: Icons.directions_car,
          actions: actions,
        ),
        child: const Text('open'),
      ),
    );

    testWidgets('shows the title, the subtitle and the rows', (tester) async {
      await tester.pumpWidget(
        _host(
          opener([
            WbSheetAction(icon: Icons.edit, label: 'Правка', onSelected: () {}),
          ]),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Машина'), findsOneWidget);
      expect(find.text('640 м'), findsOneWidget);
      expect(find.text('Правка'), findsOneWidget);
    });

    testWidgets('the chosen action runs once and the sheet goes', (
      tester,
    ) async {
      var ran = 0;
      await tester.pumpWidget(
        _host(
          opener([
            WbSheetAction(
              icon: Icons.edit,
              label: 'Правка',
              onSelected: () => ran++,
            ),
          ]),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Правка'));
      await tester.pumpAndSettle();

      expect(ran, 1);
      expect(find.byType(WbBottomSheet), findsNothing);
    });

    testWidgets('dismissing it runs nothing', (tester) async {
      var ran = false;
      await tester.pumpWidget(
        _host(
          opener([
            WbSheetAction(
              icon: Icons.edit,
              label: 'Правка',
              onSelected: () => ran = true,
            ),
          ]),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(195, 40));
      await tester.pumpAndSettle();

      expect(ran, isFalse);
      expect(find.text('Правка'), findsNothing);
    });

    testWidgets('a row is at least 56 high', (tester) async {
      await tester.pumpWidget(
        _host(
          opener([
            WbSheetAction(icon: Icons.edit, label: 'Правка', onSelected: () {}),
          ]),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final row = find.ancestor(
        of: find.text('Правка'),
        matching: find.byType(InkWell),
      );
      expect(tester.getSize(row).height, greaterThanOrEqualTo(56));
    });
  });

  group('WbUndoSnackbar', () {
    Widget host({
      required VoidCallback onUndo,
      bool accessible = false,
      bool reduceMotion = false,
    }) => MaterialApp(
      theme: WbTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          accessibleNavigation: accessible,
          disableAnimations: reduceMotion,
        ),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => WbUndoSnackbar.show(
              context,
              message: 'Удалена',
              actionLabel: 'Вернуть',
              onUndo: onUndo,
            ),
            child: const Text('go'),
          ),
        ),
      ),
    );

    Future<void> show(WidgetTester tester) async {
      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('counts down the seconds and then closes', (tester) async {
      await tester.pumpWidget(host(onUndo: () {}));
      await show(tester);
      expect(find.text('5'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(WbMotion.instant);
      expect(find.text('4'), findsOneWidget);

      await tester.pump(WbMotion.undoWindow);
      await tester.pumpAndSettle();
      expect(find.text('Удалена'), findsNothing);
    });

    testWidgets('undo runs once and closes it', (tester) async {
      var undone = 0;
      await tester.pumpWidget(host(onUndo: () => undone++));
      await show(tester);

      await tester.tap(find.text('Вернуть'));
      await tester.pumpAndSettle();

      expect(undone, 1);
      expect(find.text('Удалена'), findsNothing);
    });

    testWidgets('nothing runs when the time is up', (tester) async {
      var undone = 0;
      await tester.pumpWidget(host(onUndo: () => undone++));
      await show(tester);

      await tester.pump(WbMotion.undoWindow);
      await tester.pumpAndSettle();

      expect(undone, 0);
    });

    testWidgets('it stops in the background', (tester) async {
      await tester.pumpWidget(host(onUndo: () {}));
      await show(tester);
      void lifecycle(AppLifecycleState state) =>
          tester.binding.handleAppLifecycleStateChanged(state);

      lifecycle(AppLifecycleState.inactive);
      lifecycle(AppLifecycleState.hidden);
      await tester.pump(const Duration(seconds: 30));
      lifecycle(AppLifecycleState.inactive);
      lifecycle(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(WbMotion.instant);

      expect(find.text('Удалена'), findsOneWidget);
      await tester.pump(WbMotion.undoWindow);
      await tester.pumpAndSettle();
      expect(find.text('Удалена'), findsNothing);
    });

    testWidgets('with a screen reader it has no timer and stays', (
      tester,
    ) async {
      await tester.pumpWidget(host(onUndo: () {}, accessible: true));
      await show(tester);
      expect(find.text('5'), findsNothing);

      await tester.pump(WbMotion.undoWindow * 2);
      expect(find.text('Удалена'), findsOneWidget);
    });

    testWidgets('without animations the digits still count', (tester) async {
      await tester.pumpWidget(host(onUndo: () {}, reduceMotion: true));
      await show(tester);

      expect(find.text('5'), findsOneWidget);
      await tester.pump(WbMotion.undoWindow);
      await tester.pumpAndSettle();
    });
  });

  group('WbDialogs.prompt validation', () {
    late BuildContext context;

    Widget app({TargetPlatform platform = TargetPlatform.android}) =>
        MaterialApp(
          theme: WbTheme.light.copyWith(platform: platform),
          home: Scaffold(
            body: Builder(
              builder: (c) {
                context = c;
                return const SizedBox();
              },
            ),
          ),
        );

    Future<String?> open(
      WidgetTester tester, {
      String initial = 'Машина',
      int? maxLength,
    }) => WbDialogs.prompt(
      context,
      title: 'Название точки',
      initialValue: initial,
      confirmLabel: 'Сохранить',
      cancelLabel: 'Отмена',
      maxLength: maxLength,
      validator: (value) => value.isEmpty ? 'Введите название' : null,
    );

    Finder field() => find.byType(EditableText);

    testWidgets('an empty name shows the error and stays open', (tester) async {
      await tester.pumpWidget(app());
      unawaited(open(tester));
      await tester.pumpAndSettle();

      await tester.enterText(field(), '   ');
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      expect(find.text('Введите название'), findsOneWidget);
      expect(find.text('Название точки'), findsOneWidget);
    });

    testWidgets('no error before confirming, even when cleared', (
      tester,
    ) async {
      await tester.pumpWidget(app());
      unawaited(open(tester));
      await tester.pumpAndSettle();

      await tester.enterText(field(), '');
      await tester.pumpAndSettle();

      expect(find.text('Введите название'), findsNothing);
    });

    testWidgets('the keyboard action validates too', (tester) async {
      await tester.pumpWidget(app());
      unawaited(open(tester));
      await tester.pumpAndSettle();

      await tester.enterText(field(), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Введите название'), findsOneWidget);
      expect(tester.widget<EditableText>(field()).focusNode.hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
    });

    testWidgets('typing takes the error away and the name is saved', (
      tester,
    ) async {
      await tester.pumpWidget(app());
      final result = WbDialogs.prompt(
        context,
        title: 'Название точки',
        confirmLabel: 'Сохранить',
        validator: (value) => value.isEmpty ? 'Введите название' : null,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();
      expect(find.text('Введите название'), findsOneWidget);

      await tester.enterText(field(), '  Гараж ');
      await tester.pumpAndSettle();
      expect(find.text('Введите название'), findsNothing);

      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();
      expect(await result, 'Гараж');
    });

    testWidgets('iOS shows the error under the field', (tester) async {
      await tester.pumpWidget(app(platform: TargetPlatform.iOS));
      unawaited(open(tester));
      await tester.pumpAndSettle();

      await tester.enterText(field(), '');
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      expect(find.text('Введите название'), findsOneWidget);
      expect(find.text('Название точки'), findsOneWidget);
    });

    testWidgets('typing stops at the limit, the counter comes near it', (
      tester,
    ) async {
      await tester.pumpWidget(app());
      unawaited(open(tester, maxLength: 40));
      await tester.pumpAndSettle();
      expect(find.textContaining('/40'), findsNothing);

      await tester.enterText(field(), 'x' * 29);
      await tester.pumpAndSettle();
      expect(find.textContaining('/40'), findsNothing);

      await tester.enterText(field(), 'x' * 30);
      await tester.pumpAndSettle();
      expect(find.text('30/40'), findsOneWidget);

      await tester.enterText(field(), 'x' * 50);
      await tester.pumpAndSettle();
      expect(find.text('40/40'), findsOneWidget);
    });

    testWidgets('an older long name is kept and can only shrink', (
      tester,
    ) async {
      await tester.pumpWidget(app());
      final old = 'x' * 45;
      unawaited(open(tester, initial: old, maxLength: 40));
      await tester.pumpAndSettle();
      EditableText editable() => tester.widget<EditableText>(field());
      expect(editable().controller.text, old);

      await tester.enterText(field(), 'x' * 46);
      await tester.pumpAndSettle();
      expect(editable().controller.text, old);

      await tester.enterText(field(), 'x' * 44);
      await tester.pumpAndSettle();
      expect(editable().controller.text, 'x' * 44);
    });
  });

  group('WbTextField.maxLength', () {
    testWidgets('stops typing and counts near the limit', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _host(WbTextField(controller: controller, maxLength: 40)),
      );

      await tester.enterText(find.byType(EditableText), 'x' * 10);
      await tester.pump();
      expect(find.textContaining('/40'), findsNothing);

      await tester.enterText(find.byType(EditableText), 'x' * 60);
      await tester.pump();
      expect(controller.text, 'x' * 40);
      expect(find.text('40/40'), findsOneWidget);
    });
  });

  group('WbQrCode', () {
    testWidgets('stays square and within its limit', (tester) async {
      await tester.pumpWidget(
        _host(const WbQrCode(data: 'wayback://app/import?lat=1.5&lon=2.5')),
      );
      expect(tester.getSize(find.byType(AspectRatio)), const Size(285, 285));
    });

    testWidgets('fits a narrow screen', (tester) async {
      await tester.pumpWidget(
        _host(const SizedBox(width: 200, child: WbQrCode(data: 'wayback'))),
      );
      expect(tester.getSize(find.byType(AspectRatio)).width, 200);
    });

    testWidgets('new data draws a new code', (tester) async {
      await tester.pumpWidget(_host(const WbQrCode(data: 'a')));
      RenderCustomPaint box() => tester.renderObject<RenderCustomPaint>(
        find.descendant(
          of: find.byType(WbQrCode),
          matching: find.byType(CustomPaint),
        ),
      );
      final before = box().painter;

      await tester.pumpWidget(_host(const WbQrCode(data: 'a')));
      expect(box().painter!.shouldRepaint(before!), isFalse);

      await tester.pumpWidget(_host(const WbQrCode(data: 'b')));
      expect(box().painter!.shouldRepaint(before), isTrue);
    });
  });
}
