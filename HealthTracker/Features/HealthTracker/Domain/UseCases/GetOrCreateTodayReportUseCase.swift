import Foundation

// MARK: - Protocol

protocol GetOrCreateTodayReportUseCase {
    func execute() async throws -> DailyReport
}

// MARK: - Implementation

final class GetOrCreateTodayReportUseCaseImpl: GetOrCreateTodayReportUseCase {

    private let reportRepository: DailyReportRepository

    init(reportRepository: DailyReportRepository) {
        self.reportRepository = reportRepository
    }

    func execute() async throws -> DailyReport {
        try await reportRepository.getOrCreateTodayReport()
    }
}
