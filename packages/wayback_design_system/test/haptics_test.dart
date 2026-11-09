import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

enum _Option { a, b }

void main() {
  late List<WbHaptic> played;

  setUp(() => played = []);

  Widget host(Widget child) => MaterialApp(
    theme: WbTheme.light,
    builder: (_, app) => WbHapticsScope(player: played.add, child: app!),
    home: Scaffold(body: child),
  );

  testWidgets('without a scope nothing happens', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );

    expect(() => WbHaptics.play(context, WbHaptic.tick), returnsNormally);
  });

  testWidgets('a long press answers, a tap does not', (tester) async {
    await tester.pumpWidget(
      host(WbListItem(title: 'row', onTap: () {}, onLongPress: () {})),
    );

    await tester.tap(find.text('row'));
    await tester.pumpAndSettle();
    expect(played, isEmpty);

    await tester.longPress(find.text('row'));
    await tester.pumpAndSettle();
    expect(played, [WbHaptic.press]);
  });

  testWidgets('a long press card answers', (tester) async {
    await tester.pumpWidget(
      host(
        WbPointCard(
          title: 'Машина',
          distance: '640 м',
          typeIcon: Icons.place,
          onLongPress: () {},
        ),
      ),
    );

    await tester.longPress(find.byType(WbPointCard));
    await tester.pumpAndSettle();

    expect(played, [WbHaptic.press]);
  });

  testWidgets('the system answer is off only where ours is on', (tester) async {
    await tester.pumpWidget(
      host(
        Column(
          children: [
            WbListItem(title: 'plain', onTap: () {}),
            WbListItem(title: 'long', onLongPress: () {}),
          ],
        ),
      ),
    );

    final wells = tester.widgetList<InkWell>(find.byType(InkWell)).toList();
    expect(wells[0].enableFeedback, isTrue);
    expect(wells[1].enableFeedback, isFalse);
  });

  testWidgets('tabs answer only a new choice', (tester) async {
    await tester.pumpWidget(
      host(
        WbSegmentedTabs<_Option>(
          items: const {_Option.a: 'A', _Option.b: 'B'},
          value: _Option.a,
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('A'));
    expect(played, isEmpty);

    await tester.tap(find.text('B'));
    expect(played, [WbHaptic.tick]);
  });

  testWidgets('a switch answers', (tester) async {
    await tester.pumpWidget(
      host(WbSwitch(value: false, label: 'x', onChanged: (_) {})),
    );

    await tester.tap(find.byType(Switch));

    expect(played, [WbHaptic.tick]);
  });

  testWidgets('iOS leaves the switch to its own tap', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: WbTheme.light.copyWith(platform: TargetPlatform.iOS),
        builder: (_, app) => WbHapticsScope(player: played.add, child: app!),
        home: Scaffold(
          body: WbSwitch(value: false, label: 'x', onChanged: (_) {}),
        ),
      ),
    );

    await tester.tap(find.byType(WbSwitch).last);
    await tester.pumpAndSettle();

    expect(played, isEmpty);
  });

  testWidgets('the type picker answers only a new choice', (tester) async {
    await tester.pumpWidget(
      host(WbTypePicker(value: WbPointType.car, onChanged: (_) {})),
    );

    await tester.tap(find.byKey(const ValueKey('wb-type-car')));
    expect(played, isEmpty);

    await tester.tap(find.byKey(const ValueKey('wb-type-tent')));
    expect(played, [WbHaptic.tick]);
  });

  testWidgets('a swipe answers when the panel opens, not when it closes', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        WbSwipeActions(
          actions: [
            WbSwipeAction(icon: Icons.edit, label: 'edit', onPressed: () {}),
          ],
          child: const SizedBox(height: 72, child: Center(child: Text('row'))),
        ),
      ),
    );

    await tester.drag(find.text('row'), const Offset(-120, 0));
    await tester.pumpAndSettle();
    expect(played, [WbHaptic.tick]);

    await tester.tapAt(const Offset(100, 500));
    await tester.pumpAndSettle();
    expect(played, [WbHaptic.tick]);
  });

  testWidgets('a refused prompt warns', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      ),
    );
    final pending = WbDialogs.prompt(
      context,
      title: 'Название',
      confirmLabel: 'OK',
      cancelLabel: 'Нет',
      validator: (value) => value.isEmpty ? 'Пусто' : null,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(played, [WbHaptic.warning]);

    await tester.tap(find.text('Нет'));
    await tester.pumpAndSettle();
    await pending;
  });

  testWidgets('undo answers', (tester) async {
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => WbUndoSnackbar.show(
              context,
              message: 'Удалена',
              actionLabel: 'Вернуть',
              onUndo: () {},
            ),
            child: const Text('go'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Вернуть'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(played, [WbHaptic.tick]);
  });
}
