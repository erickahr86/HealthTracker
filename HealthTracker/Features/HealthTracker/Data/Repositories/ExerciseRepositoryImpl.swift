import Foundation
import SwiftData

// MARK: - ExerciseRepositoryImpl

final class ExerciseRepositoryImpl: ExerciseRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - ExerciseRepository

    func getAll() async throws -> [Exercise] {
        let descriptor = FetchDescriptor<ExerciseModel>(sortBy: [SortDescriptor(\.name)])
        let all = try context.fetch(descriptor).map { ExerciseMapper.toDomain($0) }
        var seen = Set<String>()
        return all.filter { seen.insert($0.name.lowercased()).inserted }
    }

    func getBy(muscleGroup: MuscleGroup) async throws -> [Exercise] {
        let raw = muscleGroup.rawValue
        let descriptor = FetchDescriptor<ExerciseModel>(
            predicate: #Predicate { $0.muscleGroupRaw == raw },
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor).map { ExerciseMapper.toDomain($0) }
    }

    func save(_ exercise: Exercise) async throws {
        if let existing = try fetchModel(id: exercise.id) {
            existing.name          = exercise.name
            existing.defaultWeight = exercise.defaultWeight
            existing.weightUnitRaw = exercise.weightUnit.rawValue
            existing.muscleGroupRaw = exercise.muscleGroup.rawValue
            existing.isCustom      = exercise.isCustom
        } else {
            context.insert(ExerciseMapper.toModel(exercise))
        }
        try context.save()
    }

    func delete(_ exercise: Exercise) async throws {
        guard let model = try fetchModel(id: exercise.id) else { return }
        context.delete(model)
        try context.save()
    }

    func getLastWeight(for exercise: Exercise) async throws -> Double? {
        let exerciseId = exercise.id
        let descriptor = FetchDescriptor<ExerciseLogModel>(
            predicate: #Predicate { $0.exercise?.id == exerciseId }
        )
        let logs = try context.fetch(descriptor)

        // Sort in-memory by report date descending
        return logs
            .sorted { ($0.report?.date ?? .distantPast) > ($1.report?.date ?? .distantPast) }
            .first?
            .weight
    }

    func deduplicateByName() async throws {
        let all = try context.fetch(FetchDescriptor<ExerciseModel>())
        var canonical: [String: ExerciseModel] = [:]
        for m in all {
            let key = m.name.lowercased()
            if canonical[key] == nil { canonical[key] = m }
        }
        let allLogs = try context.fetch(FetchDescriptor<ExerciseLogModel>())
        for log in allLogs {
            guard let ex = log.exercise else { continue }
            let key = ex.name.lowercased()
            if let c = canonical[key], c.id != ex.id { log.exercise = c }
        }
        for m in all {
            let key = m.name.lowercased()
            if let c = canonical[key], c.id != m.id { context.delete(m) }
        }
        try context.save()
    }

    // MARK: - Private

    private func fetchModel(id: UUID) throws -> ExerciseModel? {
        let descriptor = FetchDescriptor<ExerciseModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }
}
