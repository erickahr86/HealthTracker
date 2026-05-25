import Foundation

// MARK: - Protocol

protocol GetFoodsUseCase {
    func execute() async throws -> [Food]
}

// MARK: - Implementation

final class GetFoodsUseCaseImpl: GetFoodsUseCase {

    private let foodRepository: FoodRepository

    init(foodRepository: FoodRepository) {
        self.foodRepository = foodRepository
    }

    func execute() async throws -> [Food] {
        try await foodRepository.getAll()
    }
}
