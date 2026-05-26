import Foundation
import SwiftData

// MARK: - FoodModel

@Model
final class FoodModel {

    var id: UUID
    var name: String
    var unit: String
    var defaultAmount: Double
    var categoryRaw: String?     // FoodCategory.rawValue; nil for custom foods
    var isCustom: Bool

    @Relationship(deleteRule: .nullify, inverse: \MealLogModel.food)
    var logs: [MealLogModel]

    init(
        id: UUID = UUID(),
        name: String,
        unit: String,
        defaultAmount: Double,
        categoryRaw: String? = nil,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.unit = unit
        self.defaultAmount = defaultAmount
        self.categoryRaw = categoryRaw
        self.isCustom = isCustom
        self.logs = []
    }
}
