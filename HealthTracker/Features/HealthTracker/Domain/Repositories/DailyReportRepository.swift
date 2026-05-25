import Foundation

// MARK: - DailyReportRepository

protocol DailyReportRepository {
    func getOrCreateTodayReport() async throws -> DailyReport
    func save(_ report: DailyReport) async throws
    func getHistory() async throws -> [DailyReport]
    func getReport(for date: Date) async throws -> DailyReport?
    func delete(_ report: DailyReport) async throws
}
