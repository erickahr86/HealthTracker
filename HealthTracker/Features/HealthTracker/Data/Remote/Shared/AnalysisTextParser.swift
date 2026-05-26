import Foundation

// MARK: - AnalysisTextParser
// Parses the structured AI response into sections and a traffic-light value.
// Section markers are fixed ASCII tags — reliable regardless of response language.
// Shared by AnthropicMapper and GeminiMapper.

enum AnalysisTextParser {

    // MARK: - Section markers (must match SystemPrompts exactly)

    enum Marker {
        static let metabolic  = "[METABOLIC]"
        static let functional = "[FUNCTIONAL]"
        static let longevity  = "[LONGEVITY]"
        static let mission    = "[MISSION]"

        static let all = [metabolic, functional, longevity, mission]
    }

    // MARK: - Traffic light

    /// Reads the first coloured-circle emoji in the text. Defaults to yellow.
    static func parseTrafficLight(from text: String) -> TrafficLight {
        if text.contains("🟢") { return .green }
        if text.contains("🔴") { return .red   }
        return .yellow
    }

    // MARK: - Section extraction

    /// Returns the text block that starts at `startMarker` and ends before the next marker.
    /// The marker tag itself is stripped from the returned string.
    static func extractSection(from text: String, startMarker: String) -> String? {
        guard let start = text.range(of: startMarker) else { return nil }

        var end = text.endIndex
        for marker in Marker.all where marker != startMarker {
            if let next = text.range(of: marker, range: start.upperBound ..< text.endIndex) {
                if next.lowerBound < end { end = next.lowerBound }
            }
        }

        let section = String(text[start.upperBound ..< end])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return section.isEmpty ? nil : section
    }
}
