import Foundation

// MARK: - Protocol

protocol SeedFoodsUseCase {
    /// Seeds the default food catalog only when the repository is empty.
    /// Safe to call on every launch — is a no-op after the first run.
    func execute() async throws
}

// MARK: - Implementation

final class SeedFoodsUseCaseImpl: SeedFoodsUseCase {

    private let foodRepository: any FoodRepository

    init(foodRepository: any FoodRepository) {
        self.foodRepository = foodRepository
    }

    func execute() async throws {
        let existing = try await foodRepository.getAll()
        guard existing.isEmpty else { return }

        for entry in DefaultFoodCatalog.all {
            try await foodRepository.save(entry.toFood())
        }
    }
}
