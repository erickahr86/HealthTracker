import Foundation

// MARK: - FoodRepository

protocol FoodRepository {
    func getAll() async throws -> [Food]
    func save(_ food: Food) async throws
    func delete(_ food: Food) async throws
    func getLastAmount(for food: Food, in slot: MealSlot) async throws -> Double?
    func deduplicateByName() async throws
}
