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

        // Replace logs: delete existing, insert updated.
        // Important: fetch existing Food/Exercise models by UUID instead of creating new
        // instances via the mapper — creating new @Model instances causes SwiftData to
        // implicitly insert them as duplicates in the catalog.
        model.exerciseLogs.forEach { context.delete($0) }
        model.exerciseLogs = entity.exerciseLogs.map { log in
            ExerciseLogModel(
                id: log.id,
                weight: log.weight,
                weightUnitRaw: log.weightUnit.rawValue,
                exercise: fetchExerciseModel(id: log.exercise.id)
            )
        }

        model.mealLogs.forEach { context.delete($0) }
        model.mealLogs = entity.mealLogs.map { log in
            MealLogModel(
                id: log.id,
                mealSlotRaw: log.mealSlot.rawValue,
                amount: log.amount,
                freeText: log.freeText,
                photoData: log.photoData,
                food: log.food.flatMap { fetchFoodModel(id: $0.id) }
            )
        }
    }

    private func fetchFoodModel(id: UUID) -> FoodModel? {
        let descriptor = FetchDescriptor<FoodModel>(predicate: #Predicate { $0.id == id })
        return try? context.fetch(descriptor).first
    }

    private func fetchExerciseModel(id: UUID) -> ExerciseModel? {
        let descriptor = FetchDescriptor<ExerciseModel>(predicate: #Predicate { $0.id == id })
        return try? context.fetch(descriptor).first
    }
}
