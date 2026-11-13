import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

void main() {
  late List<WbHaptic> played;

  setUp(() => played = []);

  Widget host(Widget child, {ThemeData? theme, bool animations = true}) =>
      MaterialApp(
        theme: theme ?? WbTheme.light,
        builder: (_, app) => WbHapticsScope(player: played.add, child: app!),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: !animations),
          child: Scaffold(body: child),
        ),
      );

  Widget toggle({required bool dark, VoidCallback? onPressed}) =>
      WbThemeToggle(dark: dark, label: 'Сменить тему', onPressed: onPressed);

  testWidgets('the light theme shows the sun, the dark one the moon', (
    tester,
  ) async {
    await tester.pumpWidget(host(toggle(dark: false)));
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_outlined), findsNothing);

    await tester.pumpWidget(host(toggle(dark: true), theme: WbTheme.dark));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    expect(find.byIcon(Icons.light_mode_outlined), findsNothing);
  });

  testWidgets('the icons swap through a turn and a fade', (tester) async {
    await tester.pumpWidget(host(toggle(dark: false)));

    await tester.pumpWidget(host(toggle(dark: true)));
    await tester.pump();
    await tester.pump(WbMotion.base ~/ 2);
    // Halfway both icons are on screen, each part way through its turn.
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    final incoming = tester.widget<RotationTransition>(
      find
          .ancestor(
            of: find.byIcon(Icons.dark_mode_outlined),
            matching: find.byType(RotationTransition),
          )
          .first,
    );
    expect(incoming.turns.value, greaterThan(.5));
    expect(incoming.turns.value, lessThan(1));

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.light_mode_outlined), findsNothing);
  });

  testWidgets('with animations off the icon simply swaps', (tester) async {
    await tester.pumpWidget(host(toggle(dark: false), animations: false));

    await tester.pumpWidget(host(toggle(dark: true), animations: false));
    await tester.pump();
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    expect(find.byIcon(Icons.light_mode_outlined), findsNothing);
  });

  testWidgets('a tap answers with a tick and switches', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(toggle(dark: false, onPressed: () => taps++)));

    await tester.tap(find.byType(WbThemeToggle));
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(played, [WbHaptic.tick]);
  });

  testWidgets('the tap target is at least 44 and reads as a button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(toggle(dark: false, onPressed: () {})));

    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
    expect(
      tester.getSemantics(find.byType(WbThemeToggle)),
      matchesSemantics(label: 'Сменить тему', isButton: true),
    );
    handle.dispose();
  });

  testWidgets('without a handler the button is off', (tester) async {
    await tester.pumpWidget(host(toggle(dark: false)));

    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, null);
    await tester.tap(find.byType(WbThemeToggle));
    await tester.pumpAndSettle();
    expect(played, isEmpty);
  });
}
