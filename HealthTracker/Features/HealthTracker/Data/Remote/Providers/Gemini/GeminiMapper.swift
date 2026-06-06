import Foundation

// MARK: - GeminiMapper

enum GeminiMapper {

    static func toAnalysisResult(_ response: GeminiResponse) throws -> AnalysisResult {
        guard let candidate = response.candidates.first else {
            throw GeminiError.noContent
        }

        let rawText = candidate.content.parts
            .compactMap(\.text)
            .joined(separator: "\n")

        let report       = AnalysisReport.parse(from: rawText)
        let trafficLight = report.map { AnalysisTextParser.trafficLight(from: $0.trafficLight) } ?? .yellow

        return AnalysisResult(
            rawText:      rawText,
            trafficLight: trafficLight,
            tokenUsage: TokenUsage(
                inputTokens:  response.usageMetadata?.promptTokenCount     ?? 0,
                outputTokens: response.usageMetadata?.candidatesTokenCount ?? 0
            ),
            model: .geminiFlash
        )
    }
}
