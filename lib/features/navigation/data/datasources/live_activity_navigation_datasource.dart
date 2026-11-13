import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wayback/features/navigation/data/datasources/background_navigation_datasource.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_notice.dart';

/// The channel the Swift side listens on; `stopRequested` comes back the
/// other way when the user presses Stop on the activity.
const liveActivityChannelName = 'com.dogayo.wayback/live_activity';

/// iOS: a Live Activity on the lock screen and in the Dynamic Island
/// (mvp-scope.md §2.8). It is started and updated from the app process,
/// which keeps running in the background thanks to the location background
/// mode, so no push and no App Group are needed.
final class LiveActivityNavigationDatasource
    implements BackgroundNavigationDatasource {
  LiveActivityNavigationDatasource({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(liveActivityChannelName);

  final MethodChannel _channel;
  final _stopRequests = StreamController<void>.broadcast();
  var _handlerSet = false;

  @override
  Future<void> show(NavigationNotice notice) =>
      _channel.invokeMethod<void>('show', {
        'title': notice.title,
        'text': notice.text,
        'direction': notice.direction,
        'bearing': notice.bearingDegrees,
        'stopLabel': notice.stopLabel,
        'arrived': notice.arrived,
      });

  @override
  Future<void> stop() => _channel.invokeMethod<void>('stop');

  @override
  Stream<void> watchStopRequests() {
    if (!_handlerSet) {
      _handlerSet = true;
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'stopRequested') _stopRequests.add(null);
      });
    }
    return _stopRequests.stream;
  }
}
