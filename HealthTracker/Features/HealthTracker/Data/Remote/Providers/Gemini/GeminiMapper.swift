import Foundation

// MARK: - GeminiMapper

enum GeminiMapper {

    /// Converts a `GeminiResponse` into a domain `AnalysisResult`.
    /// Throws `GeminiError.noContent` when the response contains no candidates.
    static func toAnalysisResult(_ response: GeminiResponse) throws -> AnalysisResult {
        guard let candidate = response.candidates.first else {
            throw GeminiError.noContent
        }

        let rawText = candidate.content.parts
            .compactMap(\.text)
            .joined(separator: "\n")

        return AnalysisResult(
            rawText:           rawText,
            trafficLight:      AnalysisTextParser.parseTrafficLight(from: rawText),
            metabolicSection:  AnalysisTextParser.extractSection(from: rawText, startMarker: AnalysisTextParser.Marker.metabolic),
            functionalSection: AnalysisTextParser.extractSection(from: rawText, startMarker: AnalysisTextParser.Marker.functional),
            longevitySection:  AnalysisTextParser.extractSection(from: rawText, startMarker: AnalysisTextParser.Marker.longevity),
            missionSection:    AnalysisTextParser.extractSection(from: rawText, startMarker: AnalysisTextParser.Marker.mission),
            tokenUsage: TokenUsage(
                inputTokens:  response.usageMetadata?.promptTokenCount     ?? 0,
                outputTokens: response.usageMetadata?.candidatesTokenCount ?? 0
            ),
            model: .geminiFlash
        )
    }
}
