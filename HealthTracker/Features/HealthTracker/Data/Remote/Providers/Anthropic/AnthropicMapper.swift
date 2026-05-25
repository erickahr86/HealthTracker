import Foundation

// MARK: - AnthropicMapper

enum AnthropicMapper {

    /// Converts an `AnthropicResponse` into a domain `AnalysisResult`.
    static func toAnalysisResult(_ response: AnthropicResponse) -> AnalysisResult {
        let rawText = response.content
            .compactMap(\.text)
            .joined(separator: "\n")

        return AnalysisResult(
            rawText: rawText,
            trafficLight: parseTrafficLight(from: rawText),
            metabolicSection:  extractSection(from: rawText, startMarker: "📊"),
            functionalSection: extractSection(from: rawText, startMarker: "🏋️"),
            longevitySection:  extractSection(from: rawText, startMarker: "🩺"),
            missionSection:    extractSection(from: rawText, startMarker: "🎯"),
            tokenUsage: TokenUsage(
                inputTokens:  response.usage.inputTokens,
                outputTokens: response.usage.outputTokens
            )
        )
    }

    // MARK: - Private helpers

    private static let sectionMarkers = ["📊", "🏋️", "🩺", "🎯"]

    private static func parseTrafficLight(from text: String) -> TrafficLight {
        if text.contains("🟢") { return .green  }
        if text.contains("🔴") { return .red    }
        return .yellow  // default / 🟡
    }

    /// Extracts the text block that starts at `startMarker` and ends before the next section marker.
    private static func extractSection(from text: String, startMarker: String) -> String? {
        guard let start = text.range(of: startMarker) else { return nil }

        // Find the earliest start of any OTHER section marker after the current one
        var end = text.endIndex
        for marker in sectionMarkers where marker != startMarker {
            if let next = text.range(of: marker, range: start.upperBound ..< text.endIndex) {
                if next.lowerBound < end { end = next.lowerBound }
            }
        }

        let section = String(text[start.lowerBound ..< end])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return section.isEmpty ? nil : section
    }
}
