import SwiftUI
import WidgetKit

@main
struct WaybackActivityBundle: WidgetBundle {
  var body: some Widget {
    if #available(iOS 16.2, *) {
      NavigationLiveActivity()
    }
  }
}
