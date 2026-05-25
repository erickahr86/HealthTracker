import SwiftUI

// MARK: - AnalysisCardView
// Displays the stored AI analysis result.

struct AnalysisCardView: View {

    let text: String
    let trafficLight: TrafficLight?
    let analysisDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            // Header
            HStack(spacing: HTSpacing.sm) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: HTDimensions.Icon.sm, weight: .semibold))
                    .foregroundStyle(Color.htAccent)
                Text(Strings.Today.analysisSection)
                    .font(HTTypography.title3)
                Spacer()
                if let tl = trafficLight {
                    TrafficLightBadge(tl, style: .dotWithLabel)
                }
            }

            if let date = analysisDate {
                Text(Strings.Today.analyzedAt(date))
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Divider().background(Color.htBorder)

            // Analysis text
            Text(text)
                .font(HTTypography.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .htCard()
    }
}

// MARK: - Preview

#Preview {
    AnalysisCardView(
        text: """
        Overall status: Good training day.

        Metabolic: Within normal parameters. Glucose stable.
        Functional: Upper body session completed. Volume appropriate.
        Longevity: Hydration good (6 glasses). Sleep adequate at 7.5 hrs.
        Next step: Increase lower body training frequency next week.
        """,
        trafficLight: .green,
        analysisDate: Date()
    )
    .padding(HTSpacing.md)
    .background(Color.htBackground)
}
