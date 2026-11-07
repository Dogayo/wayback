import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:wayback/features/navigation/data/datasources/background_navigation_datasource.dart';
import 'package:wayback/features/navigation/domain/entities/navigation_notice.dart';

const _serviceId = 201;
const _channelId = 'navigation_progress';
const _stopButtonId = 'stop';

/// Runs in the service's own isolate, only to hear the Stop button.
@pragma('vm:entry-point')
void navigationServiceEntryPoint() =>
    FlutterForegroundTask.setTaskHandler(_StopButtonHandler());

final class _StopButtonHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onNotificationButtonPressed(String id) =>
      FlutterForegroundTask.sendDataToMain(id);
}

/// A foreground service of type location: it lets the app keep the access
/// granted "while using the app" with the screen off. GPS and the bloc stay
/// in the main isolate; the service only keeps them alive and shows the
/// notice.
final class ForegroundServiceNavigationDatasource
    implements BackgroundNavigationDatasource {
  const ForegroundServiceNavigationDatasource();

  @override
  Future<void> show(NavigationNotice notice) async {
    if (await FlutterForegroundTask.isRunningService) {
      _check(
        await FlutterForegroundTask.updateService(
          notificationTitle: notice.title,
          notificationText: notice.text,
        ),
      );
      return;
    }
    // Refused notifications hide the notice, not the service.
    if (await FlutterForegroundTask.checkNotificationPermission() !=
        NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: _channelId,
        channelName: notice.channelName,
        // Low importance folds the notice into an icon on the lock screen.
        channelImportance: NotificationChannelImportance.DEFAULT,
        priority: NotificationPriority.DEFAULT,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        allowAutoRestart: false,
        // True stops the service as soon as the app is not visible. Swiping
        // the app away is covered by android:stopWithTask in the manifest.
        stopWithTask: false,
      ),
    );
    _check(
      await FlutterForegroundTask.startService(
        serviceId: _serviceId,
        serviceTypes: [ForegroundServiceTypes.location],
        notificationTitle: notice.title,
        notificationText: notice.text,
        notificationIcon: const NotificationIcon(
          metaDataName: 'com.dogayo.wayback.NOTIFICATION_ICON',
        ),
        notificationButtons: [
          NotificationButton(id: _stopButtonId, text: notice.stopLabel),
        ],
        callback: navigationServiceEntryPoint,
      ),
    );
  }

  @override
  Future<void> stop() async {
    if (!await FlutterForegroundTask.isRunningService) return;
    _check(await FlutterForegroundTask.stopService());
  }

  @override
  Stream<void> watchStopRequests() {
    late final StreamController<void> controller;
    void onData(Object data) {
      if (data == _stopButtonId) controller.add(null);
    }

    controller = StreamController(
      onListen: () {
        FlutterForegroundTask.initCommunicationPort();
        FlutterForegroundTask.addTaskDataCallback(onData);
      },
      onCancel: () => FlutterForegroundTask.removeTaskDataCallback(onData),
    );
    return controller.stream;
  }

  static void _check(ServiceRequestResult result) {
    if (result case ServiceRequestFailure(:final error)) {
      Error.throwWithStackTrace(error, StackTrace.current);
    }
  }
}
