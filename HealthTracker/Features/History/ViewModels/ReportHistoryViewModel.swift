import Foundation

// MARK: - ReportHistoryViewModel

@MainActor @Observable
final class ReportHistoryViewModel {

    // MARK: - State

    var reports: [DailyReport] = []
    var isLoading            = false
    var errorMessage: String? = nil

    // MARK: - Dependencies

    private let getHistoryUseCase: any GetReportHistoryUseCase
    private let reportRepository:  any DailyReportRepository

    // MARK: - Init

    init(factory: FeatureFactory, reportRepository: any DailyReportRepository) {
        self.getHistoryUseCase = factory.makeGetReportHistoryUseCase()
        self.reportRepository  = reportRepository
    }

    // MARK: - Actions

    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let today = Calendar.current.startOfDay(for: Date())
            let all   = try await getHistoryUseCase.execute()
            // Exclude today's report — it's shown in the Today tab
            reports   = all.filter { Calendar.current.startOfDay(for: $0.date) < today }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteReport(_ report: DailyReport) async {
        do {
            try await reportRepository.delete(report)
            reports.removeAll { $0.id == report.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
