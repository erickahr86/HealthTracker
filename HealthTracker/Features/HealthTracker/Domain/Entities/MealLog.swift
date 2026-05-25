import Foundation

// MARK: - MealSlot

enum MealSlot: String, Codable, CaseIterable, Hashable {
    case desayuno
    case comida
    case cena
    case snack

    var displayName: String {
        NSLocalizedString("meal.slot.\(rawValue)", comment: "Meal slot display name")
    }
}

// MARK: - MealLog

struct MealLog: Identifiable, Hashable {
    let id: UUID
    var food: Food?
    var mealSlot: MealSlot
    var amount: Double?
    var freeText: String?
    var photoData: Data?

    init(
        id: UUID = UUID(),
        food: Food? = nil,
        mealSlot: MealSlot,
        amount: Double? = nil,
        freeText: String? = nil,
        photoData: Data? = nil
    ) {
        self.id = id
        self.food = food
        self.mealSlot = mealSlot
        self.amount = amount
        self.freeText = freeText
        self.photoData = photoData
    }
}
