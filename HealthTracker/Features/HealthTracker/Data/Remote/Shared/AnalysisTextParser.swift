import Foundation

// MARK: - AnalysisTextParser
// Decodes structured JSON from the AI response.
// Parsing logic lives in AnalysisReport.parse(from:) — this enum exposes helpers used by mappers.

enum AnalysisTextParser {

    static func parseReport(from text: String) -> AnalysisReport? {
        AnalysisReport.parse(from: text)
    }

    static func trafficLight(from string: String) -> TrafficLight {
        switch string.lowercased() {
        case "green": return .green
        case "red":   return .red
        default:      return .yellow
        }
    }
}
