import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Width of a compact phone; every scene is captured at this width.
const double goldenWidth = 390;

const _boundaryKey = ValueKey('wb-golden');

enum GoldenTheme { light, dark }

/// Registers one golden test per theme × platform for [scene].
///
/// Files land in `test/goldens/<name>_<platform>_<theme>.png`. Regenerate
/// them after an intentional visual change with
/// `flutter test --update-goldens test/goldens`.
void goldenScene(
  String name,
  WidgetBuilder scene, {
  List<TargetPlatform> platforms = const [TargetPlatform.android],
}) {
  for (final platform in platforms) {
    for (final theme in GoldenTheme.values) {
      final suffix = '${platform.name}_${theme.name}';
      testWidgets('$name golden ($suffix)', (tester) async {
        await pumpGoldenApp(
          tester,
          theme: theme,
          platform: platform,
          home: Scaffold(
            // Unbounded height: the image is exactly as tall as the scene,
            // so adding a variant never needs a size tweak.
            body: UnconstrainedBox(
              alignment: Alignment.topLeft,
              constrainedAxis: Axis.horizontal,
              child: RepaintBoundary(
                key: _boundaryKey,
                child: SizedBox(
                  width: goldenWidth,
                  child: Builder(
                    builder: (context) => ColoredBox(
                      color: context.wbColors.surfaceDefault,
                      child: Padding(
                        padding: const EdgeInsets.all(WbSpacing.md),
                        child: scene(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await expectLater(
          find.byKey(_boundaryKey),
          matchesGoldenFile('${name}_$suffix.png'),
        );
      });
    }
  }
}

/// Pumps a [MaterialApp] themed with the Wayback theme on a fixed viewport.
///
/// Uses fixed-duration pumps rather than `pumpAndSettle`, because the
/// skeleton shimmer and indeterminate progress never settle.
Future<void> pumpGoldenApp(
  WidgetTester tester, {
  required GoldenTheme theme,
  required TargetPlatform platform,
  required Widget home,
  double height = 1600,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = Size(goldenWidth, height);
  addTearDown(tester.view.reset);
  final base = theme == GoldenTheme.light ? WbTheme.light : WbTheme.dark;
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(platform: platform),
      home: home,
    ),
  );
  await settleFrames(tester);
}

Future<void> settleFrames(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// A captioned group of variants inside a scene.
class GoldenGroup extends StatelessWidget {
  const GoldenGroup(this.title, {required this.children, super.key});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: WbSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.wbText.labelMedium?.copyWith(
            color: context.wbColors.contentTertiary,
          ),
        ),
        const SizedBox(height: WbSpacing.xs),
        Wrap(
          spacing: WbSpacing.sm,
          runSpacing: WbSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        ),
      ],
    ),
  );
}

void noop() {}
