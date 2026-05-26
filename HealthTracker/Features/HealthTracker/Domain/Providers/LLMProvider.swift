import Foundation

// MARK: - LLMProvider

protocol LLMProvider {
    var model: AIModel { get }

    /// Analyzes a daily report using the given API key and a pre-built system prompt.
    /// The system prompt is owned by the use case layer (built dynamically from UserPreferences)
    /// so providers remain decoupled from user data.
    func analyze(report: DailyReport, apiKey: String, systemPrompt: String, hydrationUnit: HydrationUnit) async throws -> AnalysisResult
}
