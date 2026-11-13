import ActivityKit
import Flutter
import Foundation

/// The iOS side of `BackgroundNavigationDatasource` (mvp-scope.md §2.8).
///
/// Dart calls `show` on every update and `stop` when navigation closes; the
/// first `show` starts the activity, the rest update it. The Stop button of
/// the activity arrives as a notification and goes back to Dart as
/// `stopRequested`.
///
/// The activity is driven from the app process, which keeps running in the
/// background through the location background mode. Nothing here needs an
/// App Group or a push certificate.
final class LiveActivityBridge {
  static let channelName = "com.dogayo.wayback/live_activity"

  private let channel: FlutterMethodChannel
  private var current: Any?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    observeStopPresses()
  }

  deinit {
    CFNotificationCenterRemoveEveryObserver(
      CFNotificationCenterGetDarwinNotifyCenter(),
      Unmanaged.passUnretained(self).toOpaque()
    )
  }

  /// Listens for the Stop button wherever the intent ran. The callback is a
  /// C function and cannot capture, so the bridge goes through as the
  /// observer pointer.
  private func observeStopPresses() {
    CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(),
      Unmanaged.passUnretained(self).toOpaque(),
      { _, observer, _, _, _ in
        guard let observer else { return }
        let bridge = Unmanaged<LiveActivityBridge>.fromOpaque(observer)
          .takeUnretainedValue()
        DispatchQueue.main.async {
          bridge.channel.invokeMethod("stopRequested", arguments: nil)
        }
      },
      waybackStopNavigationNotification,
      nil,
      .deliverImmediately
    )
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *) else {
      // Older iOS has no Live Activities; navigation on screen is unaffected.
      result(nil)
      return
    }
    switch call.method {
    case "show":
      guard let args = call.arguments as? [String: Any],
        let title = args["title"] as? String,
        let text = args["text"] as? String,
        let stopLabel = args["stopLabel"] as? String
      else {
        result(
          FlutterError(code: "bad_args", message: "show needs title, text, stopLabel", details: nil)
        )
        return
      }
      let state = NavigationActivityAttributes.ContentState(
        text: text,
        direction: args["direction"] as? String,
        bearing: args["bearing"] as? Double,
        arrived: args["arrived"] as? Bool ?? false
      )
      show(title: title, stopLabel: stopLabel, state: state, result: result)
    case "stop":
      stop(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  @available(iOS 16.2, *)
  private func show(
    title: String,
    stopLabel: String,
    state: NavigationActivityAttributes.ContentState,
    result: @escaping FlutterResult
  ) {
    if let activity = current as? Activity<NavigationActivityAttributes> {
      Task {
        await activity.update(ActivityContent(state: state, staleDate: nil))
        result(nil)
      }
      return
    }
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      // Live Activities are off in Settings. The screen still navigates, and
      // the Dart side logs the failure.
      result(
        FlutterError(code: "activities_disabled", message: "Live Activities are off", details: nil)
      )
      return
    }
    do {
      current = try Activity.request(
        attributes: NavigationActivityAttributes(title: title, stopLabel: stopLabel),
        content: ActivityContent(state: state, staleDate: nil)
      )
      result(nil)
    } catch {
      result(
        FlutterError(code: "activity_failed", message: error.localizedDescription, details: nil)
      )
    }
  }

  /// Ends every activity of ours, not just the one this bridge started: the
  /// Stop button may have ended it already, and an activity can outlive the
  /// process that asked for it.
  private func stop(result: @escaping FlutterResult) {
    guard #available(iOS 16.2, *) else {
      result(nil)
      return
    }
    current = nil
    Task {
      for activity in Activity<NavigationActivityAttributes>.activities {
        await activity.end(nil, dismissalPolicy: .immediate)
      }
      result(nil)
    }
  }
}
