import ActivityKit
import Foundation

/// What the navigation Live Activity shows (mvp-scope.md §2.8).
///
/// Shared by the app and the widget extension: add this file to BOTH targets.
/// The point name and the button label never change while navigating, so they
/// are static attributes; everything the walk changes lives in `ContentState`.
@available(iOS 16.2, *)
struct NavigationActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    /// The distance, already formatted and localized by Dart, or the arrival
    /// line when `arrived` is true.
    var text: String

    /// Which way the point lies against north, e.g. `СЗ · 320°`.
    /// `nil` on arrival, and whenever the bearing is not worth showing.
    var direction: String?

    /// The same bearing as a number, degrees clockwise from north, for
    /// rotating the arrow. `nil` when there is no direction to show.
    var bearing: Double?

    var arrived: Bool
  }

  /// The point the walk is heading to.
  var title: String

  /// Label of the Stop button, localized by Dart.
  var stopLabel: String
}
