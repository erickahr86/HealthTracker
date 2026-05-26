import Foundation
import OSLog

// MARK: - Protocol

protocol AnalyzeReportWithAIUseCase {
    func execute(report: DailyReport) async throws -> AnalysisResult
}

// MARK: - Implementation

final class AnalyzeReportWithAIUseCaseImpl: AnalyzeReportWithAIUseCase {

    private let llmProvider:              LLMProvider
    private let aiProviderRepository:     AIProviderRepository
    private let reportRepository:         DailyReportRepository
    private let userPreferencesRepository: UserPreferencesRepository

    init(
        llmProvider:               LLMProvider,
        aiProviderRepository:      AIProviderRepository,
        reportRepository:          DailyReportRepository,
        userPreferencesRepository: UserPreferencesRepository
    ) {
        self.llmProvider               = llmProvider
        self.aiProviderRepository      = aiProviderRepository
        self.reportRepository          = reportRepository
        self.userPreferencesRepository = userPreferencesRepository
    }

    func execute(report: DailyReport) async throws -> AnalysisResult {
        let currentProvider = aiProviderRepository.getCurrentProvider()
        let apiKey          = try aiProviderRepository.getAPIKey(for: currentProvider)

        let preferences  = userPreferencesRepository.get()
        let systemPrompt = SystemPrompts.build(for: preferences)

        #if DEBUG
        let reportText = ReportFormatter.format(report, hydrationUnit: preferences.hydrationUnit)
        Logger.ai.debug("""

            ┌─ PROVIDER ──────────────────────────────────
            │ \(currentProvider.displayName, privacy: .public)
            ├─ SYSTEM PROMPT ─────────────────────────────
            \(systemPrompt, privacy: .public)
            ├─ REPORT TEXT ───────────────────────────────
            \(reportText, privacy: .public)
            └─────────────────────────────────────────────
            """)
        #endif

        let result = try await llmProvider.analyze(
            report:         report,
            apiKey:         apiKey,
            systemPrompt:   systemPrompt,
            hydrationUnit:  preferences.hydrationUnit
        )

        // Persist the analysis result back into the report
        var updatedReport = report
        updatedReport.analysisResult = result.rawText
        updatedReport.analysisDate   = result.createdAt
        updatedReport.trafficLight   = result.trafficLight
        try await reportRepository.save(updatedReport)

        return result
    }
}
