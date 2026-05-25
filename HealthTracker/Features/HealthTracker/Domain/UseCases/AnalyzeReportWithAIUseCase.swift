import Foundation

// MARK: - Protocol

protocol AnalyzeReportWithAIUseCase {
    func execute(report: DailyReport) async throws -> AnalysisResult
}

// MARK: - Implementation

final class AnalyzeReportWithAIUseCaseImpl: AnalyzeReportWithAIUseCase {

    private let llmProvider: LLMProvider
    private let aiProviderRepository: AIProviderRepository
    private let reportRepository: DailyReportRepository

    init(
        llmProvider: LLMProvider,
        aiProviderRepository: AIProviderRepository,
        reportRepository: DailyReportRepository
    ) {
        self.llmProvider = llmProvider
        self.aiProviderRepository = aiProviderRepository
        self.reportRepository = reportRepository
    }

    func execute(report: DailyReport) async throws -> AnalysisResult {
        let currentProvider = aiProviderRepository.getCurrentProvider()
        let apiKey = try aiProviderRepository.getAPIKey(for: currentProvider)

        let result = try await llmProvider.analyze(report: report, apiKey: apiKey)

        // Persist the analysis result back into the report
        var updatedReport = report
        updatedReport.analysisResult = result.rawText
        updatedReport.analysisDate = result.createdAt
        updatedReport.trafficLight = result.trafficLight
        try await reportRepository.save(updatedReport)

        return result
    }
}
