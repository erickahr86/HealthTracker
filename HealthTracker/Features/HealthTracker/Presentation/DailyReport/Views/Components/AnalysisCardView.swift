import SwiftUI

// MARK: - AnalysisCardView
// Displays the stored AI analysis result broken into labelled sections.
// Falls back to showing the full raw text when no section markers are found
// (e.g. legacy data or unexpected model output).

struct AnalysisCardView: View {

    let text:         String
    let trafficLight: TrafficLight?
    let analysisDate: Date?

    // MARK: - Section definitions

    private struct SectionDef {
        let marker:      String
        let title:       String
        let systemImage: String
    }

    private let sectionDefs: [SectionDef] = [
        SectionDef(marker: AnalysisTextParser.Marker.metabolic,
                   title:       Strings.Analysis.metabolic,
                   systemImage: "chart.bar.fill"),
        SectionDef(marker: AnalysisTextParser.Marker.functional,
                   title:       Strings.Analysis.functional,
                   systemImage: "dumbbell.fill"),
        SectionDef(marker: AnalysisTextParser.Marker.longevity,
                   title:       Strings.Analysis.longevity,
                   systemImage: "stethoscope"),
        SectionDef(marker: AnalysisTextParser.Marker.mission,
                   title:       Strings.Analysis.mission,
                   systemImage: "flag.checkered"),
    ]

    // MARK: - Parsed content

    private struct ParsedSection: Identifiable {
        let id = UUID()
        let def:  SectionDef
        let body: String
    }

    private var parsedSections: [ParsedSection] {
        sectionDefs.compactMap { def in
            guard let body = AnalysisTextParser.extractSection(from: text, startMarker: def.marker),
                  !body.isEmpty else { return nil }
            return ParsedSection(def: def, body: body)
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            cardHeader

            if let date = analysisDate {
                Text(Strings.Today.analyzedAt(date))
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Divider().background(Color.htBorder)

            if parsedSections.isEmpty {
                // Fallback: raw text (no markers detected)
                Text(.init(text))
                    .font(HTTypography.body)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            } else {
                sectionsView
            }
        }
        .htCard()
    }

    // MARK: - Header

    private var cardHeader: some View {
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
    }

    // MARK: - Sections

    private var sectionsView: some View {
        VStack(alignment: .leading, spacing: HTSpacing.md) {
            ForEach(parsedSections) { section in
                sectionRow(section)

                if section.id != parsedSections.last?.id {
                    Divider().background(Color.htBorder)
                }
            }
        }
    }

    private func sectionRow(_ section: ParsedSection) -> some View {
        VStack(alignment: .leading, spacing: HTSpacing.xs) {
            Label(section.def.title, systemImage: section.def.systemImage)
                .font(HTTypography.subheadlineBold)
                .foregroundStyle(Color.htAccent)

            Text(.init(section.body))
                .font(HTTypography.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        AnalysisCardView(
            text: """
            [METABOLIC]
            Estimated intake: ~1,850 kcal | Protein: 145 g | Fiber: 28 g
            Glycemic load: moderate. Good macro balance. Kidney load within range.

            Traffic light: 🟢 Green — solid training and nutrition day.

            [FUNCTIONAL]
            Upper body session completed. Volume appropriate for the week.
            Consider adding one lower-body session.

            [LONGEVITY]
            Blood pressure within range. Sleep duration optimal.
            Hydration above daily minimum — good renal support.

            [MISSION]
            Add a 20-min walk after dinner to improve post-meal glucose response.
            """,
            trafficLight: .green,
            analysisDate: Date()
        )
        .padding(HTSpacing.md)
    }
    .background(Color.htBackground)
    .preferredColorScheme(.dark)
}
