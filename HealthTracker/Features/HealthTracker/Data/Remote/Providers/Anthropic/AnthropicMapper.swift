import Foundation

// MARK: - AnthropicMapper

enum AnthropicMapper {

    static func toAnalysisResult(_ response: AnthropicResponse) -> AnalysisResult {
        let rawText = response.content
            .compactMap(\.text)
            .joined(separator: "\n")

        let report       = AnalysisReport.parse(from: rawText)
        let trafficLight = report.map { AnalysisTextParser.trafficLight(from: $0.trafficLight) } ?? .yellow

        return AnalysisResult(
            rawText:      rawText,
            trafficLight: trafficLight,
            tokenUsage: TokenUsage(
                inputTokens:  response.usage.inputTokens,
                outputTokens: response.usage.outputTokens
            ),
            model: .claudeSonnet
        )
    }
}
