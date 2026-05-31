import Foundation

// MARK: - Protocol

protocol SeedFoodsUseCase {
    /// Seeds the default food catalog only when the repository is empty.
    /// Safe to call on every launch — is a no-op after the first run.
    func execute() async throws
}

// MARK: - Implementation

final class SeedFoodsUseCaseImpl: SeedFoodsUseCase {

    private let foodRepository:           any FoodRepository
    private let userPreferencesRepository: any UserPreferencesRepository

    init(
        foodRepository:           any FoodRepository,
        userPreferencesRepository: any UserPreferencesRepository
    ) {
        self.foodRepository            = foodRepository
        self.userPreferencesRepository = userPreferencesRepository
    }

    func execute() async throws {
        guard !userPreferencesRepository.hasSeedInitialFoods() else { return }

        for entry in DefaultFoodCatalog.all {
            try await foodRepository.save(entry.toFood())
        }
        userPreferencesRepository.setHasSeedInitialFoods(true)
    }
}
