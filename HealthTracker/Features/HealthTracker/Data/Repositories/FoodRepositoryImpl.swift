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
        let descriptor = FetchDescriptor<FoodModel>(sortBy: [SortDescriptor(\.name)])
        let all = try context.fetch(descriptor).map { FoodMapper.toDomain($0) }
        var seen = Set<String>()
        return all.filter { seen.insert($0.name.lowercased()).inserted }
    }

    func save(_ food: Food) async throws {
        if let existing = try fetchModel(id: food.id) {
            existing.name          = food.name
            existing.unit          = food.unit
            existing.defaultAmount = food.defaultAmount
            existing.categoryRaw   = food.category?.rawValue
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

    func deduplicateByName() async throws {
        let all = try context.fetch(FetchDescriptor<FoodModel>())
        var canonical: [String: FoodModel] = [:]
        for m in all {
            let key = m.name.lowercased()
            if canonical[key] == nil { canonical[key] = m }
        }
        let allLogs = try context.fetch(FetchDescriptor<MealLogModel>())
        for log in allLogs {
            guard let food = log.food else { continue }
            let key = food.name.lowercased()
            if let c = canonical[key], c.id != food.id { log.food = c }
        }
        for m in all {
            let key = m.name.lowercased()
            if let c = canonical[key], c.id != m.id { context.delete(m) }
        }
        try context.save()
    }

    // MARK: - Private

    private func fetchModel(id: UUID) throws -> FoodModel? {
        let descriptor = FetchDescriptor<FoodModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }
}
