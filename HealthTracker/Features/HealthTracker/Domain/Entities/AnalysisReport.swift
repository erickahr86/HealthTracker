import Foundation
import OSLog

// MARK: - AnalysisReport
// Top-level JSON structure returned by the AI for a daily analysis.

struct AnalysisReport: Codable {
    let trafficLight: String   // "green" | "yellow" | "red"
    let title: String?
    let subtitle: String?
    let sections: [AnalysisSection]

    // MARK: - Parsing

    // Multi-strategy extractor that handles code fences, preamble text, and raw JSON.
    static func parse(from text: String) -> AnalysisReport? {
        let candidates: [String] = jsonCandidates(from: text)
        for candidate in candidates {
            guard let data = candidate.data(using: .utf8) else { continue }
            do {
                return try JSONDecoder().decode(AnalysisReport.self, from: data)
            } catch {
                #if DEBUG
                Logger.ai.debug("JSON decode failed (\(candidate.prefix(80))): \(error)")
                #endif
            }
        }
        #if DEBUG
        Logger.ai.debug("AnalysisReport.parse: no candidate decoded. Raw text prefix: \(text.prefix(200))")
        #endif
        return nil
    }

    // Returns candidate JSON strings to try, from most to least specific.
    private static func jsonCandidates(from text: String) -> [String] {
        var candidates: [String] = []

        // 1. ```json ... ```
        if let s = text.range(of: "```json"),
           let e = text.range(of: "```", range: s.upperBound..<text.endIndex) {
            candidates.append(
                String(text[s.upperBound..<e.lowerBound])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }

        // 2. ``` ... ``` (no language tag)
        if let s = text.range(of: "```"),
           let e = text.range(of: "```", range: s.upperBound..<text.endIndex) {
            candidates.append(
                String(text[s.upperBound..<e.lowerBound])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }

        // 3. First { ... last } — strips any preamble/postamble the AI might add
        if let s = text.firstIndex(of: "{"),
           let e = text.lastIndex(of: "}"),
           s <= e {
            candidates.append(String(text[s...e]))
        }

        // 4. Full trimmed text as-is
        candidates.append(text.trimmingCharacters(in: .whitespacesAndNewlines))

        return candidates
    }
}

// MARK: - AnalysisSection

struct AnalysisSection: Codable, Identifiable {
    let id: String
    let number: Int
    let title: String
    let type: String   // "richText" | "meals" | "totals" | "hydration" | "bullets" | "conditionImpacts"

    // richText
    let blocks: [MarkdownBlock]?

    // meals
    let note: String?
    let meals: [MealBreakdown]?

    // totals
    let totals: MacroTotals?
    let targets: MacroTargets?
    let commentary: [MacroCommentary]?

    // renal
    let subtitle: String?
    let rows: [RenalRow]?
    let callout: RenalCallout?

    // bullets
    let bullets: [BulletPoint]?

    // conditionImpacts
    let impacts: [ConditionImpact]?
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

struct MacroTarget: Codable {
    let min: Double
    let optimal: Double
    let max: Double
}

struct MacroTargets: Codable {
    let protein: MacroTarget
    let carbs: MacroTarget
    let fat: MacroTarget
    let kcal: MacroTarget
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

struct ConditionImpact: Codable {
    let id: String           // matches ChronicCondition.rawValue, e.g. "fattyLiver"
    let title: String        // localized condition name from the AI
    let trafficLight: String // "green" | "yellow" | "red"
    let text: String         // clinical description, **bold** and *italic* allowed
    let rows: [RenalRow]?    // NKF food semaphore rows — only populated for renalDisease
}
