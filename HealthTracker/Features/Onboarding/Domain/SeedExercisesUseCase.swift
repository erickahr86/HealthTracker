import Foundation

// MARK: - Protocol

protocol SeedExercisesUseCase {
    /// Persists a batch of exercises. Non-throwing per-item: failures are
    /// silently skipped so a single bad entry doesn't abort the whole batch.
    func execute(_ exercises: [Exercise]) async throws
}

// MARK: - Implementation

final class SeedExercisesUseCaseImpl: SeedExercisesUseCase {

    private let exerciseRepository: any ExerciseRepository

    init(exerciseRepository: any ExerciseRepository) {
        self.exerciseRepository = exerciseRepository
    }

    func execute(_ exercises: [Exercise]) async throws {
        for exercise in exercises {
            try await exerciseRepository.save(exercise)
        }
    }
}
