import Foundation

// MARK: - ExerciseRepository

protocol ExerciseRepository {
    func getAll() async throws -> [Exercise]
    func getBy(muscleGroup: MuscleGroup) async throws -> [Exercise]
    func save(_ exercise: Exercise) async throws
    func delete(_ exercise: Exercise) async throws
    func getLastWeight(for exercise: Exercise) async throws -> Double?
    func deduplicateByName() async throws
}
