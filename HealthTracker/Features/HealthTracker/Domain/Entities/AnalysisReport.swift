import Foundation

// MARK: - AnalysisReport
// Top-level JSON structure returned by the AI for a daily analysis.

struct AnalysisReport: Codable {
    let trafficLight: String   // "green" | "yellow" | "red"
    let title: String?
    let subtitle: String?
    let sections: [AnalysisSection]

    // MARK: - Parsing

    static func parse(from text: String) -> AnalysisReport? {
        let json: String
        if let fenceStart = text.range(of: "```json"),
           let fenceEnd   = text.range(of: "```", range: fenceStart.upperBound..<text.endIndex) {
            json = String(text[fenceStart.upperBound..<fenceEnd.lowerBound])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            json = text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(AnalysisReport.self, from: data)
    }
}

// MARK: - AnalysisSection

struct AnalysisSection: Codable, Identifiable {
    let id: String
    let number: Int
    let title: String
    let type: String   // "richText" | "meals" | "totals" | "renal" | "bullets"

    // richText
    let blocks: [MarkdownBlock]?

    // meals
    let note: String?
    let meals: [MealBreakdown]?

    // totals
    let totals: MacroTotals?
    let commentary: [MacroCommentary]?

    // renal
    let subtitle: String?
    let rows: [RenalRow]?
    let callout: RenalCallout?

    // bullets
    let bullets: [BulletPoint]?
}

// MARK: - Section content types

struct MarkdownBlock: Codable {
    let type: String
    let md: String
}

struct MealBreakdown: Codable, Identifiable {
    let id: String
    let label: String
    let subtitle: String?
    let items: [FoodItem]

    var totalProtein: Double { items.reduce(0) { $0 + $1.protein } }
    var totalCarbs:   Double { items.reduce(0) { $0 + $1.carbs   } }
    var totalFat:     Double { items.reduce(0) { $0 + $1.fat     } }
    var totalKcal:    Double { items.reduce(0) { $0 + $1.kcal    } }
}

struct FoodItem: Codable {
    let name: String
    let portion: String
    let protein: Double
    let carbs: Double
    let fat: Double
    let kcal: Double
}

struct MacroTotals: Codable {
    let protein: Double
    let carbs: Double
    let fat: Double
    let kcal: Double
}

struct MacroCommentary: Codable {
    let key: String   // "protein" | "carbs" | "fat" | "kcal"
    let title: String
    let text: String
}

struct RenalRow: Codable {
    let items: String
    let status: String   // "green" | "yellow" | "red"
    let label: String
    let reason: String
}

struct RenalCallout: Codable {
    let icon: String
    let title: String
    let text: String
}

struct BulletPoint: Codable {
    let title: String
    let text: String
}
