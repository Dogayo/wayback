import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

enum _Units { metric, imperial }

Widget _host(
  Widget child, {
  ThemeData? theme,
  TextScaler textScaler = TextScaler.noScaling,
}) => MaterialApp(
  theme: theme ?? WbTheme.light,
  home: MediaQuery(
    data: MediaQueryData(textScaler: textScaler),
    child: Scaffold(body: SizedBox(width: 358, child: child)),
  ),
);

// The test font draws every glyph a full em wide, so labels are short
// unless a test is about wrapping.
Widget _tabs(
  _Units value,
  ValueChanged<_Units> onChanged, {
  String metric = 'Метры',
  String imperial = 'Футы',
}) => WbSegmentedTabs(
  items: {_Units.metric: metric, _Units.imperial: imperial},
  value: value,
  onChanged: onChanged,
);

Finder _segment(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(Container)).first;

final _plate = find.byKey(const ValueKey('wb-segment-plate'));

Color? _plateColor(WidgetTester tester) =>
    ((tester.widget<SizedBox>(_plate).child! as DecoratedBox).decoration
            as BoxDecoration)
        .color;

void main() {
  testWidgets('segments split the track equally, 44 high', (tester) async {
    await tester.pumpWidget(_host(_tabs(_Units.metric, (_) {})));

    final track = tester.getSize(find.byType(WbSegmentedTabs<_Units>));
    expect(track, const Size(358, 44));
    final metric = tester.getSize(_segment('Метры'));
    final imperial = tester.getSize(_segment('Футы'));
    expect(metric, imperial);
    expect(metric.height, 36);
  });

  testWidgets('the plate sits under the chosen segment', (tester) async {
    await tester.pumpWidget(_host(_tabs(_Units.metric, (_) {})));

    expect(_plate, findsOneWidget);
    expect(_plateColor(tester), WbColors.light.segmentSelected);
    expect(tester.getRect(_plate), tester.getRect(_segment('Метры')));
  });

  testWidgets('the plate slides to a new choice', (tester) async {
    await tester.pumpWidget(_host(_tabs(_Units.metric, (_) {})));
    final from = tester.getRect(_plate).left;
    final to = tester.getRect(_segment('Футы')).left;

    await tester.pumpWidget(_host(_tabs(_Units.imperial, (_) {})));
    await tester.pump(WbMotion.base ~/ 2);
    final halfway = tester.getRect(_plate).left;
    expect(halfway, greaterThan(from));
    expect(halfway, lessThan(to));

    await tester.pumpAndSettle();
    expect(tester.getRect(_plate), tester.getRect(_segment('Футы')));
  });

  testWidgets('dark theme uses its own track and plate', (tester) async {
    await tester.pumpWidget(
      _host(_tabs(_Units.metric, (_) {}), theme: WbTheme.dark),
    );

    final track = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(WbSegmentedTabs<_Units>),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(
      (track.decoration! as BoxDecoration).color,
      WbColors.dark.segmentTrack,
    );
    expect(_plateColor(tester), WbColors.dark.segmentSelected);
  });

  testWidgets('a tap anywhere in a segment picks it', (tester) async {
    _Units? picked;
    await tester.pumpWidget(_host(_tabs(_Units.metric, (v) => picked = v)));

    final segment = tester.getRect(_segment('Футы'));
    // The track edge above the plate still belongs to the segment.
    await tester.tapAt(segment.topCenter.translate(0, -2));
    expect(picked, _Units.imperial);
  });

  testWidgets('the chosen segment reads as selected', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(_tabs(_Units.imperial, (_) {})));

    expect(
      tester.getSemantics(find.text('Футы')),
      matchesSemantics(
        label: 'Футы',
        isButton: true,
        hasSelectedState: true,
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('labels wrap at 200% text instead of overflowing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        _tabs(
          _Units.metric,
          (_) {},
          metric: 'Метры и километры',
          imperial: 'Футы и мили',
        ),
        textScaler: const TextScaler.linear(2),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(WbSegmentedTabs<_Units>)).height,
      greaterThan(44),
    );
  });
}
