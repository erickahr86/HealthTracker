import SwiftUI

// MARK: - AnalysisCardView
// Accordion-style view for the JSON-structured AI daily analysis.
// Falls back to raw text display if JSON decoding fails.

struct AnalysisCardView: View {

    let text:         String
    let trafficLight: TrafficLight?
    let analysisDate: Date?

    @State private var parsedReport: AnalysisReport? = nil
    @State private var expanded: Set<String> = []

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

            if let report = parsedReport {
                accordionView(report)
            } else {
                Text(text)
                    .font(HTTypography.body)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
        .htCard()
        .task(id: text) {
            parsedReport = AnalysisReport.parse(from: text)
            if let first = parsedReport?.sections.first {
                expanded = [first.id]
            }
        }
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

    // MARK: - Accordion

    private func accordionView(_ report: AnalysisReport) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(report.sections.enumerated()), id: \.element.id) { idx, section in
                if idx > 0 { Divider().background(Color.htBorder) }
                accordionRow(section)
            }
        }
    }

    @ViewBuilder
    private func accordionRow(_ section: AnalysisSection) -> some View {
        let isExpanded = expanded.contains(section.id)

        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: HTSpacing.sm) {
                numberBadge(section.number)
                Text(section.title)
                    .font(HTTypography.bodyMedium)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: HTDimensions.Icon.sm - 2, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isExpanded)
            }
            .padding(.vertical, HTSpacing.xs)
            .contentShape(Rectangle())
            .onTapGesture { toggleSection(section.id) }

            if isExpanded {
                Divider().background(Color.htBorder)
                sectionContent(section)
                    .padding(.top, HTSpacing.sm)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: isExpanded)
    }

    private func toggleSection(_ id: String) {
        if expanded.contains(id) {
            expanded.remove(id)
        } else {
            expanded.insert(id)
        }
    }

    // MARK: - Number badge

    private func numberBadge(_ number: Int) -> some View {
        ZStack {
            Circle()
                .fill(Color.htAccent)
                .frame(width: 24, height: 24)
            Text("\(number)")
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Section content router

    @ViewBuilder
    private func sectionContent(_ section: AnalysisSection) -> some View {
        switch section.type {
        case "richText":
            richTextContent(section)
        case "meals":
            mealsContent(section)
        case "totals":
            totalsContent(section)
        case "renal":
            renalContent(section)
        case "bullets":
            bulletsContent(section)
        default:
            EmptyView()
        }
    }

    // MARK: - richText renderer

    private func richTextContent(_ section: AnalysisSection) -> some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            ForEach(section.blocks ?? [], id: \.md) { block in
                Text(attrStr(block.md))
                    .font(HTTypography.body)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
    }

    // MARK: - meals renderer

    private func mealsContent(_ section: AnalysisSection) -> some View {
        VStack(alignment: .leading, spacing: HTSpacing.md) {
            if let note = section.note {
                Text(note)
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }

            ForEach(section.meals ?? []) { meal in
                mealBlock(meal)
            }
        }
    }

    private func mealBlock(_ meal: MealBreakdown) -> some View {
        VStack(alignment: .leading, spacing: HTSpacing.xs) {
            // Meal header
            HStack(alignment: .firstTextBaseline, spacing: HTSpacing.xs) {
                Text(meal.label)
                    .font(HTTypography.subheadlineBold)
                    .foregroundStyle(Color.htAccent)
                if let sub = meal.subtitle {
                    Text("— \(sub)")
                        .font(HTTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Column headers
            macroColumnHeader()

            // Food items
            ForEach(meal.items, id: \.name) { item in
                foodItemRow(item)
            }

            // Subtotal
            Divider().background(Color.htBorder)
            subtotalRow(meal)
        }
    }

    private func macroColumnHeader() -> some View {
        HStack(spacing: 0) {
            Spacer()
            Text("P")
                .font(HTTypography.captionBold)
                .foregroundStyle(.secondary)
                .frame(width: 34, alignment: .trailing)
            Text("C")
                .font(HTTypography.captionBold)
                .foregroundStyle(.secondary)
                .frame(width: 34, alignment: .trailing)
            Text("G")
                .font(HTTypography.captionBold)
                .foregroundStyle(.secondary)
                .frame(width: 34, alignment: .trailing)
            Text("kcal")
                .font(HTTypography.captionBold)
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .trailing)
        }
    }

    private func foodItemRow(_ item: FoodItem) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(item.name)
                    .font(HTTypography.caption)
                    .foregroundStyle(.primary)
                Text(item.portion)
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(formatMacro(item.protein))
                .font(HTTypography.caption)
                .frame(width: 34, alignment: .trailing)
            Text(formatMacro(item.carbs))
                .font(HTTypography.caption)
                .frame(width: 34, alignment: .trailing)
            Text(formatMacro(item.fat))
                .font(HTTypography.caption)
                .frame(width: 34, alignment: .trailing)
            Text(formatMacro(item.kcal))
                .font(HTTypography.caption)
                .frame(width: 44, alignment: .trailing)
        }
    }

    private func subtotalRow(_ meal: MealBreakdown) -> some View {
        HStack(spacing: 0) {
            Text(Strings.Analysis.macroSubtotal)
                .font(HTTypography.captionBold)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(formatMacro(meal.totalProtein))
                .font(HTTypography.captionBold)
                .frame(width: 34, alignment: .trailing)
            Text(formatMacro(meal.totalCarbs))
                .font(HTTypography.captionBold)
                .frame(width: 34, alignment: .trailing)
            Text(formatMacro(meal.totalFat))
                .font(HTTypography.captionBold)
                .frame(width: 34, alignment: .trailing)
            Text(formatMacro(meal.totalKcal))
                .font(HTTypography.captionBold)
                .frame(width: 44, alignment: .trailing)
        }
    }

    // MARK: - totals renderer

    private func totalsContent(_ section: AnalysisSection) -> some View {
        VStack(alignment: .leading, spacing: HTSpacing.md) {
            if let t = section.totals {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: HTSpacing.sm
                ) {
                    macroPillCard(label: Strings.Analysis.macroProtein, value: t.protein, unit: "g")
                    macroPillCard(label: Strings.Analysis.macroCarbs,   value: t.carbs,   unit: "g")
                    macroPillCard(label: Strings.Analysis.macroFat,     value: t.fat,     unit: "g")
                    macroPillCard(label: Strings.Analysis.macroKcal,    value: t.kcal,    unit: "")
                }
            }

            if let commentary = section.commentary, !commentary.isEmpty {
                Divider().background(Color.htBorder)
                VStack(alignment: .leading, spacing: HTSpacing.sm) {
                    ForEach(commentary, id: \.key) { item in
                        VStack(alignment: .leading, spacing: HTSpacing.xxs) {
                            Text(item.title)
                                .font(HTTypography.subheadlineBold)
                                .foregroundStyle(Color.htAccent)
                            Text(attrStr(item.text))
                                .font(HTTypography.body)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                        }
                    }
                }
            }
        }
    }

    private func macroPillCard(label: String, value: Double, unit: String) -> some View {
        VStack(spacing: HTSpacing.xxs) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(formatTotal(value))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.htAccent)
                if !unit.isEmpty {
                    Text(unit)
                        .font(HTTypography.captionBold)
                        .foregroundStyle(.secondary)
                }
            }
            Text(label)
                .font(HTTypography.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HTSpacing.sm)
        .background(Color.htSurfaceVariant)
        .clipShape(RoundedRectangle(cornerRadius: HTDimensions.CornerRadius.md))
    }

    // MARK: - renal renderer

    private func renalContent(_ section: AnalysisSection) -> some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            if let subtitle = section.subtitle {
                Text(subtitle)
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: HTSpacing.sm) {
                ForEach(section.rows ?? [], id: \.items) { row in
                    renalRowView(row)
                }
            }

            if let callout = section.callout {
                renalCalloutView(callout)
            }
        }
    }

    private func renalRowView(_ row: RenalRow) -> some View {
        HStack(alignment: .top, spacing: HTSpacing.sm) {
            Circle()
                .fill(statusColor(row.status))
                .frame(width: 10, height: 10)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: HTSpacing.xxs) {
                Text(row.label)
                    .font(HTTypography.captionBold)
                    .foregroundStyle(statusColor(row.status))
                Text(row.items)
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
                Text(row.reason)
                    .font(HTTypography.caption)
                    .foregroundStyle(.primary)
            }
        }
    }

    private func renalCalloutView(_ callout: RenalCallout) -> some View {
        HStack(alignment: .top, spacing: HTSpacing.sm) {
            Text(callout.icon)
                .font(.title3)
            VStack(alignment: .leading, spacing: HTSpacing.xxs) {
                Text(callout.title)
                    .font(HTTypography.subheadlineBold)
                    .foregroundStyle(.primary)
                Text(attrStr(callout.text))
                    .font(HTTypography.body)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
        .padding(HTSpacing.sm)
        .background(Color.htSurfaceVariant)
        .clipShape(RoundedRectangle(cornerRadius: HTDimensions.CornerRadius.sm))
    }

    // MARK: - bullets renderer

    private func bulletsContent(_ section: AnalysisSection) -> some View {
        VStack(alignment: .leading, spacing: HTSpacing.md) {
            ForEach(section.bullets ?? [], id: \.title) { bullet in
                VStack(alignment: .leading, spacing: HTSpacing.xxs) {
                    Text(bullet.title)
                        .font(HTTypography.subheadlineBold)
                        .foregroundStyle(Color.htAccent)
                    Text(attrStr(bullet.text))
                        .font(HTTypography.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
            }
        }
    }

    // MARK: - Helpers

    private func attrStr(_ md: String) -> AttributedString {
        (try? AttributedString(
            markdown: md,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(md)
    }

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "green": return Color.htTrafficGreen
        case "red":   return Color.htTrafficRed
        default:      return Color.htTrafficYellow
        }
    }

    private func formatMacro(_ value: Double) -> String {
        value == 0 ? "—" : String(format: value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f", value)
    }

    private func formatTotal(_ value: Double) -> String {
        String(format: value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f", value)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        AnalysisCardView(
            text: previewJSON,
            trafficLight: .green,
            analysisDate: Date()
        )
        .padding(HTSpacing.md)
    }
    .background(Color.htBackground)
    .preferredColorScheme(.dark)
}

private let previewJSON = """
{
  "trafficLight": "green",
  "title": "Daily Report",
  "subtitle": "Physiological, nutritional and metabolic synthesis",
  "sections": [
    {
      "id": "physiological", "number": 1,
      "title": "Brief Physiological Analysis",
      "type": "richText",
      "blocks": [
        {"type":"p","md":"Sleeping **8 hours and 51 minutes** is the cornerstone of today's outstanding performance. You entered the gym with a fully restored central nervous system."},
        {"type":"p","md":"Notable volume on the leg press with **81 kg** and adaptation on the *hip thrust* machine. Raising your steps to **8,500** reactivated daily energy expenditure excellently."}
      ]
    },
    {
      "id": "macros", "number": 2,
      "title": "Macronutrient and Calorie Breakdown",
      "type": "meals",
      "note": "Pork is calculated using the average profile of a lean cut, cooked and stewed.",
      "meals": [
        {
          "id": "breakfast", "label": "Breakfast", "subtitle": "Linear Energy",
          "items": [
            {"name":"Oatmeal","portion":"1/2 cup (~40g)","protein":5.3,"carbs":27.0,"fat":3.0,"kcal":150},
            {"name":"Peanut butter","portion":"30g","protein":7.5,"carbs":6.0,"fat":15.0,"kcal":194}
          ]
        },
        {
          "id": "lunch", "label": "Lunch", "subtitle": "Post-Workout Substrate",
          "items": [
            {"name":"Whole eggs","portion":"4 pieces","protein":25.2,"carbs":1.6,"fat":20.0,"kcal":288},
            {"name":"Refried beans","portion":"80g","protein":4.0,"carbs":12.0,"fat":2.5,"kcal":90},
            {"name":"Corn tortillas","portion":"4 pieces","protein":6.4,"carbs":42.0,"fat":2.0,"kcal":200}
          ]
        },
        {
          "id": "dinner", "label": "Dinner", "subtitle": "Nocturnal Reconstruction",
          "items": [
            {"name":"Stewed pork","portion":"140g","protein":36.4,"carbs":0.0,"fat":11.2,"kcal":256}
          ]
        },
        {
          "id": "snack", "label": "Snack", "subtitle": "Clean Traces",
          "items": [
            {"name":"Small apple","portion":"1 piece","protein":0.5,"carbs":20.6,"fat":0.2,"kcal":77}
          ]
        }
      ]
    },
    {
      "id": "totals", "number": 3,
      "title": "Daily Summary",
      "type": "totals",
      "totals": {"protein":94.7,"carbs":172.2,"fat":56.2,"kcal":1554},
      "commentary": [
        {"key":"protein","title":"Protein","text":"Solid structural contribution. The combination of eggs and 140g pork efficiently covers the amino acid block needed to repair fibers."},
        {"key":"carbs","title":"Carbohydrates","text":"Very balanced distribution. Starches from potatoes, 8 tortillas total, and oatmeal precisely refueled the muscle glycogen tanks."},
        {"key":"fat","title":"Fat","text":"Moderate-low range and extremely clean. Dominated by unsaturated fats from peanut butter and egg yolks."},
        {"key":"kcal","title":"Calories","text":"Clean and controlled caloric deficit. Combining high expenditure from 8,500 steps and training with this intake forces the body to oxidize fat tissue."}
      ]
    },
    {
      "id": "renal", "number": 4,
      "title": "Renal Health Semaphore",
      "type": "renal",
      "subtitle": "NKF Guidelines",
      "rows": [
        {"items":"Oatmeal, Peanut Butter, Eggs, Pork, Apple","status":"green","label":"Green","reason":"Natural, dense foods free of chemical additives. Lean pork provides potassium and excellent amino acid bioavailability."},
        {"items":"Corn tortillas, Refried beans","status":"yellow","label":"Yellow","reason":"Safe base sources. Beans may add a baseline of sodium if commercial, perfectly controlled by portion."}
      ],
      "callout": {"icon":"💧","title":"Hydroelectrolyte Balance","text":"Your **120 oz of water** completely protected your kidneys today. With 8,500 steps and gym sweat, this liquid maintained perfect blood volume."}
    },
    {
      "id": "metabolic", "number": 5,
      "title": "Metabolic Diagnosis",
      "type": "bullets",
      "bullets": [
        {"title":"Sleep-Training Synergy","text":"Entering a session with nearly 9 hours of rest drastically reduces morning cortisol. This optimizes insulin sensitivity, directing carbohydrates almost magnetically toward skeletal muscle."},
        {"title":"Structural Consistency","text":"Today you completely eliminated the sodium spikes from yesterday. Your body will use previously retained water to process today's clean load, likely resulting in a natural fluid discharge in the coming days."}
      ]
    }
  ]
}
"""
