import SwiftUI

// MARK: - HTTypography
// Font scale for HealthTracker, built on SF Pro (system font).
// Use these constants instead of inline .font() calls.

enum HTTypography {
    static let largeTitle  = Font.system(.largeTitle,   design: .default, weight: .bold)
    static let title1      = Font.system(.title,        design: .default, weight: .bold)
    static let title2      = Font.system(.title2,       design: .default, weight: .semibold)
    static let title3      = Font.system(.title3,       design: .default, weight: .semibold)
    static let headline    = Font.system(.headline,     design: .default, weight: .semibold)
    static let body        = Font.system(.body,         design: .default, weight: .regular)
    static let bodyMedium  = Font.system(.body,         design: .default, weight: .medium)
    static let bodyBold    = Font.system(.body,         design: .default, weight: .semibold)
    static let callout     = Font.system(.callout,      design: .default, weight: .regular)
    static let subheadline     = Font.system(.subheadline,  design: .default, weight: .medium)
    static let subheadlineBold = Font.system(.subheadline,  design: .default, weight: .semibold)
    static let footnote    = Font.system(.footnote,     design: .default, weight: .regular)
    static let caption     = Font.system(.caption,      design: .default, weight: .regular)
    static let captionBold = Font.system(.caption,      design: .default, weight: .semibold)
    static let caption2    = Font.system(.caption2,     design: .default, weight: .medium)
}
