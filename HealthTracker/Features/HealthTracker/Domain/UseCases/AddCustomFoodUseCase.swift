import Foundation

// MARK: - Protocol

protocol AddCustomFoodUseCase {
    func execute(name: String, unit: String, defaultAmount: Double) async throws -> Food
}

// MARK: - Implementation

final class AddCustomFoodUseCaseImpl: AddCustomFoodUseCase {

    private let foodRepository: FoodRepository

    init(foodRepository: FoodRepository) {
        self.foodRepository = foodRepository
    }

    func execute(name: String, unit: String, defaultAmount: Double) async throws -> Food {
        let food = Food(
            name: name,
            unit: unit,
            defaultAmount: defaultAmount,
            isCustom: true
        )
        try await foodRepository.save(food)
        return food
    }
}
