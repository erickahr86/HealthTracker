import Foundation

// MARK: - Protocol

protocol GetExercisesUseCase {
    func execute(filter: MuscleGroup?) async throws -> [Exercise]
}

// MARK: - Implementation

final class GetExercisesUseCaseImpl: GetExercisesUseCase {

    private let exerciseRepository: ExerciseRepository

    init(exerciseRepository: ExerciseRepository) {
        self.exerciseRepository = exerciseRepository
    }

    func execute(filter: MuscleGroup? = nil) async throws -> [Exercise] {
        if let filter {
            return try await exerciseRepository.getBy(muscleGroup: filter)
        }
        return try await exerciseRepository.getAll()
    }
}
