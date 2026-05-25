import Foundation
import SwiftData

// MARK: - DailyReportRepositoryImpl

final class DailyReportRepositoryImpl: DailyReportRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - DailyReportRepository

    func getOrCreateTodayReport() async throws -> DailyReport {
        if let existing = try fetchTodayModel() {
            return DailyReportMapper.toDomain(existing)
        }

        let today = Calendar.current.startOfDay(for: Date())
        let newReport = DailyReport(date: today)
        let model = DailyReportMapper.toModel(newReport)
        context.insert(model)
        try context.save()
        return newReport
    }

    func save(_ report: DailyReport) async throws {
        if let existing = try fetchModel(id: report.id) {
            update(existing, from: report)
        } else {
            context.insert(DailyReportMapper.toModel(report))
        }
        try context.save()
    }

    func getHistory() async throws -> [DailyReport] {
        let descriptor = FetchDescriptor<DailyReportModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor).map { DailyReportMapper.toDomain($0) }
    }

    func getReport(for date: Date) async throws -> DailyReport? {
        let start = Calendar.current.startOfDay(for: date)
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return nil }

        let descriptor = FetchDescriptor<DailyReportModel>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        return try context.fetch(descriptor).first.map { DailyReportMapper.toDomain($0) }
    }

    func delete(_ report: DailyReport) async throws {
        guard let model = try fetchModel(id: report.id) else { return }
        context.delete(model)
        try context.save()
    }

    // MARK: - Private helpers

    private func fetchTodayModel() throws -> DailyReportModel? {
        let start = Calendar.current.startOfDay(for: Date())
        guard let end = Calendar.current.date(byAdding: .day, value: 1, to: start) else { return nil }

        let descriptor = FetchDescriptor<DailyReportModel>(
            predicate: #Predicate { $0.date >= start && $0.date < end }
        )
        return try context.fetch(descriptor).first
    }

    private func fetchModel(id: UUID) throws -> DailyReportModel? {
        let descriptor = FetchDescriptor<DailyReportModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    private func update(_ model: DailyReportModel, from entity: DailyReport) {
        model.isRestDay      = entity.isRestDay
        model.steps          = entity.steps
        model.waterGlasses   = entity.waterGlasses
        model.energyLevel    = entity.energyLevel
        model.sleepHours     = entity.sleepHours
        model.glucoseMgdl    = entity.glucoseMgdl
        model.bloodPressure  = entity.bloodPressure
        model.notes          = entity.notes
        model.analysisResult = entity.analysisResult
        model.analysisDate   = entity.analysisDate
        model.trafficLightRaw = entity.trafficLight?.rawValue

        // Replace logs: delete existing, insert updated
        model.exerciseLogs.forEach { context.delete($0) }
        model.exerciseLogs = entity.exerciseLogs.map { ExerciseLogMapper.toModel($0) }

        model.mealLogs.forEach { context.delete($0) }
        model.mealLogs = entity.mealLogs.map { MealLogMapper.toModel($0) }
    }
}
