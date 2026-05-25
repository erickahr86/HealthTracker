import SwiftUI

// MARK: - HTColors
// All semantic color tokens for HealthTracker.
// Each token is adaptive: it automatically uses the correct value
// for the system's current color scheme (light / dark).

extension Color {

    // MARK: Backgrounds

    /// Main app background.
    /// Dark: #0F1117 — Light: #F2F2F7
    static let htBackground = Color(
        light: Color(hex: "F2F2F7"),
        dark:  Color(hex: "0F1117")
    )

    /// Card and sheet surface.
    /// Dark: #1A1D26 — Light: #FFFFFF
    static let htSurface = Color(
        light: Color(hex: "FFFFFF"),
        dark:  Color(hex: "1A1D26")
    )

    /// Elevated surface or secondary section backgrounds.
    /// Dark: #22263A — Light: #F0F2F5
    static let htSurfaceVariant = Color(
        light: Color(hex: "F0F2F5"),
        dark:  Color(hex: "22263A")
    )

    // MARK: Borders

    /// Subtle card border.
    /// Dark: #2E3650 — Light: #D1D5DB
    static let htBorder = Color(
        light: Color(hex: "D1D5DB"),
        dark:  Color(hex: "2E3650")
    )

    // MARK: Accent

    /// Primary accent / interactive color.
    /// Dark: #82B1FF — Light: #4A7FDB (darker for WCAG AA contrast)
    static let htAccent = Color(
        light: Color(hex: "4A7FDB"),
        dark:  Color(hex: "82B1FF")
    )

    // MARK: Traffic Light (same in both modes)

    static let htTrafficGreen  = Color(hex: "4CAF82")
    static let htTrafficYellow = Color(hex: "F6C453")
    static let htTrafficRed    = Color(hex: "F07070")

    // MARK: Semantic helpers

    /// Tinted background for a given traffic light state.
    static func htTrafficBackground(_ light: TrafficLight?) -> Color {
        switch light {
        case .green:  return Color(hex: "4CAF82").opacity(0.12)
        case .yellow: return Color(hex: "F6C453").opacity(0.12)
        case .red:    return Color(hex: "F07070").opacity(0.12)
        case nil:     return .htSurface
        }
    }

    /// Returns the solid traffic light color for a given state.
    static func htTrafficColor(_ light: TrafficLight?) -> Color {
        switch light {
        case .green:  return .htTrafficGreen
        case .yellow: return .htTrafficYellow
        case .red:    return .htTrafficRed
        case nil:     return .secondary
        }
    }
}
