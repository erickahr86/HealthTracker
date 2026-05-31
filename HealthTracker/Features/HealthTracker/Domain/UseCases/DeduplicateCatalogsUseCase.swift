import Foundation

// MARK: - Protocol

protocol DeduplicateCatalogsUseCase {
    func execute() async throws
}

// MARK: - Implementation

final class DeduplicateCatalogsUseCaseImpl: DeduplicateCatalogsUseCase {

    private let exerciseRepository: any ExerciseRepository
    private let foodRepository:     any FoodRepository

    init(exerciseRepository: any ExerciseRepository, foodRepository: any FoodRepository) {
        self.exerciseRepository = exerciseRepository
        self.foodRepository     = foodRepository
    }

    func execute() async throws {
        try await exerciseRepository.deduplicateByName()
        try await foodRepository.deduplicateByName()
    }
}
