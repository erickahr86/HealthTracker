import Foundation

// MARK: - Protocol

protocol SaveDailyReportUseCase {
    func execute(_ report: DailyReport) async throws
}

// MARK: - Implementation

final class SaveDailyReportUseCaseImpl: SaveDailyReportUseCase {

    private let reportRepository: DailyReportRepository

    init(reportRepository: DailyReportRepository) {
        self.reportRepository = reportRepository
    }

    func execute(_ report: DailyReport) async throws {
        try await reportRepository.save(report)
    }
}
