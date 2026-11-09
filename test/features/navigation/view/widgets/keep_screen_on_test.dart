import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/core/platform/screen_awake.dart';
import 'package:wayback/features/navigation/view/widgets/keep_screen_on.dart';

void main() {
  final calls = <Object?>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ScreenAwake.channel, (call) async {
          calls.add(call.arguments);
          return null;
        });
  });

  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ScreenAwake.channel, null),
  );

  testWidgets('holds the screen on only while in the tree', (tester) async {
    await tester.pumpWidget(const KeepScreenOn(child: SizedBox()));
    expect(calls, [true]);

    await tester.pumpWidget(const SizedBox());
    expect(calls, [true, false]);
  });

  testWidgets('a platform without the channel is not an error', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ScreenAwake.channel, null);

    await tester.pumpWidget(const KeepScreenOn(child: SizedBox()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
