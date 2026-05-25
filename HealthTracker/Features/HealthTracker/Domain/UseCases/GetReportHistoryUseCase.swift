import Foundation

// MARK: - Protocol

protocol GetReportHistoryUseCase {
    func execute() async throws -> [DailyReport]
}

// MARK: - Implementation

final class GetReportHistoryUseCaseImpl: GetReportHistoryUseCase {

    private let reportRepository: DailyReportRepository

    init(reportRepository: DailyReportRepository) {
        self.reportRepository = reportRepository
    }

    func execute() async throws -> [DailyReport] {
        try await reportRepository.getHistory()
    }
}
