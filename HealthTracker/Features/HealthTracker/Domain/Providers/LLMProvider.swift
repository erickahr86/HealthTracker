import Foundation

// MARK: - LLMProvider

protocol LLMProvider {
    var model: AIModel { get }
    func analyze(report: DailyReport, apiKey: String) async throws -> AnalysisResult
}
