import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

/// Wayback tokens (DESIGN_SYSTEM.md §Color) as explicit light and dark sets.
///
/// The lock screen banner does NOT pick a set and does not tint its own
/// background: iOS draws it on a material of its own choosing, and the
/// `colorScheme` the widget sees does not always match that material — a
/// banner can end up light while the widget is told it is dark, which left
/// pale text on white. So the banner takes the system's own `.primary` and
/// `.secondary` for text and keeps tokens only for the brand accents, which
/// read on either material. The Dynamic Island is always black, so it does
/// take the dark set.
private struct Theme {
  let surface: Color
  let container: Color
  let primary: Color
  let secondary: Color
  let brand: Color
  let positive: Color
  let arrowLit: Color

  /// Functional borders and the darker arrow facet are the same in both
  /// themes, so they are not part of the pair.
  static let border = Color(hex: 0x6B7885)  // borderDefault
  static let arrowShade = Color(hex: 0xC24812)  // actionPrimaryBg

  static let dark = Theme(
    surface: Color(hex: 0x1B2025),
    container: Color(hex: 0x14181D),
    primary: Color(hex: 0xF5F7F9),
    secondary: Color(hex: 0xAEB8C2),
    brand: Color(hex: 0xF97A2E),
    positive: Color(hex: 0x34A873),
    arrowLit: Color(hex: 0xF97A2E)
  )

  /// For the lock screen: text follows the system, accents stay ours.
  static let adaptive = Theme(
    surface: .clear,
    container: Color.primary.opacity(0.08),
    primary: .primary,
    secondary: .secondary,
    brand: Color(hex: 0xC24812),  // actionPrimaryBg reads on both materials
    positive: Color(hex: 0x197A4D),
    arrowLit: Color(hex: 0xE2591A)
  )
}

extension Color {
  fileprivate init(hex: UInt32) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255,
      opacity: 1
    )
  }
}

/// The Wayback arrow: two facets, the nose longer than the tail, like the
/// app icon. Same geometry as `_paintArrow` in `wb_direction_dial.dart`, so
/// the banner and the navigation screen draw one shape.
@available(iOS 16.2, *)
private struct FacetedArrow: View {
  let theme: Theme

  var body: some View {
    GeometryReader { geo in
      let r = min(geo.size.width, geo.size.height) / 2
      let cx = geo.size.width / 2
      let cy = geo.size.height / 2
      let tip = CGPoint(x: cx, y: cy - r)
      let notch = CGPoint(x: cx, y: cy + r * 0.3)
      let left = CGPoint(x: cx - r * 0.52, y: cy + r * 0.62)
      let right = CGPoint(x: cx + r * 0.52, y: cy + r * 0.62)
      ZStack {
        Path { path in
          path.move(to: tip)
          path.addLine(to: notch)
          path.addLine(to: left)
          path.closeSubpath()
        }
        .fill(theme.arrowLit)
        Path { path in
          path.move(to: tip)
          path.addLine(to: right)
          path.addLine(to: notch)
          path.closeSubpath()
        }
        .fill(Theme.arrowShade)
      }
    }
  }
}

/// The dial: the bearing arrow while walking, a filled dot on arrival.
@available(iOS 16.2, *)
private struct DirectionDial: View {
  let state: NavigationActivityAttributes.ContentState
  let theme: Theme
  let size: CGFloat

  var body: some View {
    ZStack {
      Circle().fill(theme.container)
      if state.arrived {
        Circle()
          .fill(theme.positive)
          .frame(width: size * 0.43, height: size * 0.43)
      } else if let bearing = state.bearing {
        FacetedArrow(theme: theme)
          .frame(width: size * 0.5, height: size * 0.5)
          .rotationEffect(.degrees(bearing))
      }
    }
    .frame(width: size, height: size)
  }
}

/// Name, and under it the direction or the arrival line.
@available(iOS 16.2, *)
private struct TitleBlock: View {
  let title: String
  let state: NavigationActivityAttributes.ContentState
  let theme: Theme

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title)
        .font(.system(size: 17, weight: .semibold))
        .foregroundStyle(theme.primary)
        .lineLimit(1)
      if state.arrived {
        Text(state.text)
          .font(.system(size: 15))
          .foregroundStyle(theme.positive)
          .lineLimit(1)
      } else if let direction = state.direction {
        Text(direction)
          .font(.system(size: 13))
          .foregroundStyle(theme.secondary)
          .lineLimit(1)
      }
    }
  }
}

/// The distance, dropped on arrival: the title block already says it.
@available(iOS 16.2, *)
private struct DistanceLabel: View {
  let state: NavigationActivityAttributes.ContentState
  let theme: Theme

  var body: some View {
    if !state.arrived {
      Text(state.text)
        .font(.system(size: 34, weight: .bold))
        .foregroundStyle(theme.primary)
        .lineLimit(1)
        .minimumScaleFactor(0.6)
    }
  }
}

/// Before iOS 17 a Live Activity carries no button; navigation is then
/// closed by opening the app.
@available(iOS 16.2, *)
private struct StopButton: View {
  let label: String
  let theme: Theme

  var body: some View {
    if #available(iOS 17.0, *) {
      Button(intent: StopNavigationIntent()) {
        Text(label)
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(theme.brand)
          .frame(maxWidth: .infinity, minHeight: 40)
      }
      .buttonStyle(.plain)
      .overlay(
        RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1)
      )
    }
  }
}

@available(iOS 16.2, *)
private struct LockScreenView: View {
  let attributes: NavigationActivityAttributes
  let state: NavigationActivityAttributes.ContentState

  var body: some View {
    let theme = Theme.adaptive
    VStack(spacing: 12) {
      HStack(alignment: .center, spacing: 16) {
        DirectionDial(state: state, theme: theme, size: 56)
        TitleBlock(title: attributes.title, state: state, theme: theme)
        Spacer(minLength: 8)
        DistanceLabel(state: state, theme: theme)
      }
      StopButton(label: attributes.stopLabel, theme: theme)
    }
    .padding(16)
  }
}

@available(iOS 16.2, *)
struct NavigationLiveActivity: Widget {
  /// The Dynamic Island is always on black, so it always takes the dark set.
  private let island = Theme.dark

  var body: some WidgetConfiguration {
    ActivityConfiguration(for: NavigationActivityAttributes.self) { context in
      LockScreenView(attributes: context.attributes, state: context.state)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          DirectionDial(state: context.state, theme: island, size: 48)
        }
        DynamicIslandExpandedRegion(.trailing) {
          DistanceLabel(state: context.state, theme: island)
        }
        DynamicIslandExpandedRegion(.center) {
          TitleBlock(
            title: context.attributes.title,
            state: context.state,
            theme: island
          )
        }
        DynamicIslandExpandedRegion(.bottom) {
          StopButton(label: context.attributes.stopLabel, theme: island)
        }
      } compactLeading: {
        DirectionDial(state: context.state, theme: island, size: 24)
      } compactTrailing: {
        Text(context.state.text)
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(
            context.state.arrived ? island.positive : island.primary
          )
          .lineLimit(1)
      } minimal: {
        DirectionDial(state: context.state, theme: island, size: 24)
      }
    }
  }
}
