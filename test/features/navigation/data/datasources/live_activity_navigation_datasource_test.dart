import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wayback/features/navigation/data/datasources/live_activity_navigation_datasource.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_notice.dart';

const _notice = NavigationNotice(
  title: 'Домик',
  text: '640 м',
  stopLabel: 'Завершить навигацию',
  channelName: 'Навигация',
  direction: 'СЗ · 320°',
  bearingDegrees: 320,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(liveActivityChannelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  late LiveActivityNavigationDatasource datasource;

  setUp(() {
    calls.clear();
    datasource = LiveActivityNavigationDatasource();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('show', () {
    test('sends everything the activity draws', () async {
      await datasource.show(_notice);

      expect(calls.single.method, 'show');
      expect(calls.single.arguments, {
        'title': 'Домик',
        'text': '640 м',
        'direction': 'СЗ · 320°',
        'bearing': 320.0,
        'stopLabel': 'Завершить навигацию',
        'arrived': false,
      });
    });

    test('on arrival there is no direction left to send', () async {
      await datasource.show(
        const NavigationNotice(
          title: 'Домик',
          text: 'Где-то рядом',
          stopLabel: 'Завершить навигацию',
          channelName: 'Навигация',
          arrived: true,
        ),
      );

      final args = calls.single.arguments as Map<Object?, Object?>;
      expect(args['arrived'], isTrue);
      expect(args['direction'], isNull);
      expect(args['bearing'], isNull);
    });

    test('an update is another show, not a second start', () async {
      await datasource.show(_notice);
      await datasource.show(_notice);

      expect(calls.map((c) => c.method), ['show', 'show']);
    });
  });

  test('stop takes no arguments', () async {
    await datasource.stop();

    expect(calls.single.method, 'stop');
    expect(calls.single.arguments, isNull);
  });

  group('watchStopRequests', () {
    Future<void> pressStop() => messenger.handlePlatformMessage(
      liveActivityChannelName,
      const StandardMethodCodec().encodeMethodCall(
        const MethodCall('stopRequested'),
      ),
      (_) {},
    );

    test('a press on the activity reaches the stream', () async {
      final requests = datasource.watchStopRequests();
      final first = requests.first;

      await pressStop();

      await expectLater(first, completes);
    });

    test('other platform calls are ignored', () async {
      var seen = 0;
      datasource.watchStopRequests().listen((_) => seen++);

      await messenger.handlePlatformMessage(
        liveActivityChannelName,
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('somethingElse'),
        ),
        (_) {},
      );
      await pressStop();
      await Future<void>.delayed(Duration.zero);

      expect(seen, 1);
    });
  });
}
