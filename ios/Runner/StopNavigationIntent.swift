import ActivityKit
import AppIntents
import Foundation

/// The name both processes agree on for "Stop was pressed".
///
/// It travels as a Darwin notification, which crosses process boundaries: a
/// `LiveActivityIntent` is meant to run in the app, but the same type is
/// compiled into the widget extension too, and the system may run it there.
/// An ordinary `NotificationCenter` post would then never reach the app.
/// Darwin notifications need no App Group and carry no payload, which is all
/// this needs — the press itself is the whole message.
let waybackStopNavigationNotification = "com.dogayo.wayback.stopNavigation" as CFString

/// The Stop button of the Live Activity (mvp-scope.md §2.8).
///
/// Shared by the app and the widget extension: it belongs to BOTH targets.
@available(iOS 17.0, *)
struct StopNavigationIntent: LiveActivityIntent {
  static var title: LocalizedStringResource = "End navigation"

  init() {}

  func perform() async throws -> some IntentResult {
    // End the activity here rather than waiting for the app to do it: with
    // the screen locked Flutter gets to the Dart side only once the app is
    // brought forward, and until then the banner would sit there ignoring
    // the press.
    for activity in Activity<NavigationActivityAttributes>.activities {
      await activity.end(nil, dismissalPolicy: .immediate)
    }
    // The app still has to leave the navigation screen; it picks this up
    // whenever it next runs.
    CFNotificationCenterPostNotification(
      CFNotificationCenterGetDarwinNotifyCenter(),
      CFNotificationName(waybackStopNavigationNotification),
      nil,
      nil,
      true
    )
    return .result()
  }
}
