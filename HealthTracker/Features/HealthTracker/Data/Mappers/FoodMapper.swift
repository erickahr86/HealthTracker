import Foundation

// MARK: - FoodMapper

enum FoodMapper {

    static func toDomain(_ model: FoodModel) -> Food {
        Food(
            id: model.id,
            name: model.name,
            unit: model.unit,
            defaultAmount: model.defaultAmount,
            isCustom: model.isCustom
        )
    }

    static func toModel(_ entity: Food) -> FoodModel {
        FoodModel(
            id: entity.id,
            name: entity.name,
            unit: entity.unit,
            defaultAmount: entity.defaultAmount,
            isCustom: entity.isCustom
        )
    }
}

// MARK: - MealLogMapper

enum MealLogMapper {

    static func toDomain(_ model: MealLogModel) -> MealLog {
        MealLog(
            id: model.id,
            food: model.food.map { FoodMapper.toDomain($0) },
            mealSlot: MealSlot(rawValue: model.mealSlotRaw) ?? .desayuno,
            amount: model.amount,
            freeText: model.freeText,
            photoData: model.photoData
        )
    }

    static func toModel(_ entity: MealLog) -> MealLogModel {
        MealLogModel(
            id: entity.id,
            mealSlotRaw: entity.mealSlot.rawValue,
            amount: entity.amount,
            freeText: entity.freeText,
            photoData: entity.photoData,
            food: entity.food.map { FoodMapper.toModel($0) }
        )
    }
}
