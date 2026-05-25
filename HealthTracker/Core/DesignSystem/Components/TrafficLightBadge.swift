import SwiftUI

// MARK: - TrafficLightBadge
// Displays the day's health indicator: green / yellow / red.

struct TrafficLightBadge: View {

    let trafficLight: TrafficLight?
    var style: Style

    enum Style {
        case dot                // small colored dot only
        case dotWithLabel       // dot + localized label
        case banner             // full-width tinted banner
    }

    init(_ trafficLight: TrafficLight?, style: Style = .dot) {
        self.trafficLight = trafficLight
        self.style = style
    }

    var body: some View {
        switch style {
        case .dot:
            dotView
        case .dotWithLabel:
            HStack(spacing: HTSpacing.xxs) {
                dotView
                Text(label)
                    .font(HTTypography.captionBold)
                    .foregroundStyle(color)
            }
        case .banner:
            bannerView
        }
    }

    // MARK: - Sub-views

    private var dotView: some View {
        Circle()
            .fill(color)
            .frame(
                width:  HTDimensions.TrafficLight.dotSize,
                height: HTDimensions.TrafficLight.dotSize
            )
    }

    private var bannerView: some View {
        HStack(spacing: HTSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
            Text(label)
                .font(HTTypography.subheadline)
                .foregroundStyle(color)
            Spacer()
        }
        .padding(.horizontal, HTSpacing.md)
        .frame(height: HTDimensions.TrafficLight.badgeHeight)
        .background(Color.htTrafficBackground(trafficLight))
        .clipShape(RoundedRectangle(cornerRadius: HTDimensions.CornerRadius.sm))
    }

    // MARK: - Helpers

    private var color: Color { .htTrafficColor(trafficLight) }

    private var label: String {
        switch trafficLight {
        case .green:  return NSLocalizedString("trafficlight.green",  comment: "")
        case .yellow: return NSLocalizedString("trafficlight.yellow", comment: "")
        case .red:    return NSLocalizedString("trafficlight.red",    comment: "")
        case nil:     return "—"
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: HTSpacing.md) {
        HStack(spacing: HTSpacing.lg) {
            TrafficLightBadge(.green)
            TrafficLightBadge(.yellow)
            TrafficLightBadge(.red)
            TrafficLightBadge(nil)
        }
        TrafficLightBadge(.green,  style: .dotWithLabel)
        TrafficLightBadge(.yellow, style: .dotWithLabel)
        TrafficLightBadge(.red,    style: .dotWithLabel)
        TrafficLightBadge(.green,  style: .banner)
        TrafficLightBadge(.yellow, style: .banner)
        TrafficLightBadge(.red,    style: .banner)
    }
    .padding(HTSpacing.md)
    .background(Color.htBackground)
}
