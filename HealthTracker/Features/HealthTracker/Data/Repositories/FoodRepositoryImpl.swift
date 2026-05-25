import Foundation
import SwiftData

// MARK: - FoodRepositoryImpl

final class FoodRepositoryImpl: FoodRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - FoodRepository

    func getAll() async throws -> [Food] {
        let descriptor = FetchDescriptor<FoodModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor).map { FoodMapper.toDomain($0) }
    }

    func save(_ food: Food) async throws {
        if let existing = try fetchModel(id: food.id) {
            existing.name          = food.name
            existing.unit          = food.unit
            existing.defaultAmount = food.defaultAmount
            existing.isCustom      = food.isCustom
        } else {
            context.insert(FoodMapper.toModel(food))
        }
        try context.save()
    }

    func delete(_ food: Food) async throws {
        guard let model = try fetchModel(id: food.id) else { return }
        context.delete(model)
        try context.save()
    }

    func getLastAmount(for food: Food, in slot: MealSlot) async throws -> Double? {
        let foodId  = food.id
        let slotRaw = slot.rawValue

        let descriptor = FetchDescriptor<MealLogModel>(
            predicate: #Predicate { $0.food?.id == foodId && $0.mealSlotRaw == slotRaw }
        )
        let logs = try context.fetch(descriptor)

        return logs
            .sorted { ($0.report?.date ?? .distantPast) > ($1.report?.date ?? .distantPast) }
            .first?
            .amount
    }

    // MARK: - Private

    private func fetchModel(id: UUID) throws -> FoodModel? {
        let descriptor = FetchDescriptor<FoodModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }
}
