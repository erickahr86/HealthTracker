import Foundation

// MARK: - DefaultFoodEntry
// A catalog entry used to auto-seed the food repository on first launch.
// `nameKey` resolves via Localizable.strings (EN + ES) so the persisted name
// matches the device locale at seed time.
// Units use short universal abbreviations understood in both languages.

struct DefaultFoodEntry {
    let nameKey:       String        // Localizable.strings key
    let unit:          String        // "g" | "ml" | "pza" | "taza" | "cdas"
    let defaultAmount: Double
    let category:      FoodCategory

    var name: String {
        NSLocalizedString(nameKey, comment: "Food name")
    }

    func toFood() -> Food {
        Food(
            name:          name,
            unit:          unit,
            defaultAmount: defaultAmount,
            category:      category,
            isCustom:      false
        )
    }
}

// MARK: - DefaultFoodCatalog
// 39 common foods: 7 categories covering a typical healthy diet.
// Extend freely — SeedFoodsUseCase inserts all entries only when the DB is empty.

enum DefaultFoodCatalog {

    static let all: [DefaultFoodEntry] = protein + grains + vegetables + fruits + dairy + legumes + other

    // MARK: Protein (8)

    static let protein: [DefaultFoodEntry] = [
        .init(nameKey: "food.protein.chicken_breast", unit: "g",   defaultAmount: 150, category: .protein),
        .init(nameKey: "food.protein.ground_beef",    unit: "g",   defaultAmount: 120, category: .protein),
        .init(nameKey: "food.protein.egg",            unit: "pza", defaultAmount: 2,   category: .protein),
        .init(nameKey: "food.protein.tuna",           unit: "g",   defaultAmount: 120, category: .protein),
        .init(nameKey: "food.protein.salmon",         unit: "g",   defaultAmount: 150, category: .protein),
        .init(nameKey: "food.protein.beef_fillet",    unit: "g",   defaultAmount: 150, category: .protein),
        .init(nameKey: "food.protein.shrimp",         unit: "g",   defaultAmount: 100, category: .protein),
        .init(nameKey: "food.protein.pork",           unit: "g",   defaultAmount: 120, category: .protein),
    ]

    // MARK: Grains (6)

    static let grains: [DefaultFoodEntry] = [
        .init(nameKey: "food.grains.white_rice",    unit: "g",   defaultAmount: 100, category: .grains),
        .init(nameKey: "food.grains.corn_tortilla", unit: "pza", defaultAmount: 2,   category: .grains),
        .init(nameKey: "food.grains.whole_bread",   unit: "pza", defaultAmount: 2,   category: .grains),
        .init(nameKey: "food.grains.oats",          unit: "g",   defaultAmount: 80,  category: .grains),
        .init(nameKey: "food.grains.potato",        unit: "g",   defaultAmount: 150, category: .grains),
        .init(nameKey: "food.grains.sweet_potato",  unit: "g",   defaultAmount: 150, category: .grains),
    ]

    // MARK: Vegetables (7)

    static let vegetables: [DefaultFoodEntry] = [
        .init(nameKey: "food.vegetables.tomato",   unit: "pza", defaultAmount: 1,   category: .vegetables),
        .init(nameKey: "food.vegetables.lettuce",  unit: "g",   defaultAmount: 50,  category: .vegetables),
        .init(nameKey: "food.vegetables.cucumber", unit: "pza", defaultAmount: 1,   category: .vegetables),
        .init(nameKey: "food.vegetables.carrot",   unit: "pza", defaultAmount: 1,   category: .vegetables),
        .init(nameKey: "food.vegetables.broccoli", unit: "g",   defaultAmount: 100, category: .vegetables),
        .init(nameKey: "food.vegetables.spinach",  unit: "g",   defaultAmount: 80,  category: .vegetables),
        .init(nameKey: "food.vegetables.nopal",    unit: "g",   defaultAmount: 100, category: .vegetables),
    ]

    // MARK: Fruits (6)

    static let fruits: [DefaultFoodEntry] = [
        .init(nameKey: "food.fruits.apple",       unit: "pza", defaultAmount: 1,   category: .fruits),
        .init(nameKey: "food.fruits.banana",      unit: "pza", defaultAmount: 1,   category: .fruits),
        .init(nameKey: "food.fruits.orange",      unit: "pza", defaultAmount: 1,   category: .fruits),
        .init(nameKey: "food.fruits.mango",       unit: "pza", defaultAmount: 1,   category: .fruits),
        .init(nameKey: "food.fruits.watermelon",  unit: "g",   defaultAmount: 200, category: .fruits),
        .init(nameKey: "food.fruits.strawberries",unit: "g",   defaultAmount: 100, category: .fruits),
    ]

    // MARK: Dairy (4)

    static let dairy: [DefaultFoodEntry] = [
        .init(nameKey: "food.dairy.milk",           unit: "ml", defaultAmount: 250, category: .dairy),
        .init(nameKey: "food.dairy.plain_yogurt",   unit: "g",  defaultAmount: 150, category: .dairy),
        .init(nameKey: "food.dairy.fresh_cheese",   unit: "g",  defaultAmount: 50,  category: .dairy),
        .init(nameKey: "food.dairy.cottage_cheese", unit: "g",  defaultAmount: 150, category: .dairy),
    ]

    // MARK: Legumes (3)

    static let legumes: [DefaultFoodEntry] = [
        .init(nameKey: "food.legumes.black_beans", unit: "taza", defaultAmount: 1, category: .legumes),
        .init(nameKey: "food.legumes.pinto_beans", unit: "taza", defaultAmount: 1, category: .legumes),
        .init(nameKey: "food.legumes.lentils",     unit: "taza", defaultAmount: 1, category: .legumes),
    ]

    // MARK: Other (5)

    static let other: [DefaultFoodEntry] = [
        .init(nameKey: "food.other.avocado",        unit: "pza",  defaultAmount: 0.5, category: .other),
        .init(nameKey: "food.other.almonds",        unit: "g",    defaultAmount: 30,  category: .other),
        .init(nameKey: "food.other.walnut",         unit: "g",    defaultAmount: 30,  category: .other),
        .init(nameKey: "food.other.olive_oil",      unit: "cdas", defaultAmount: 1,   category: .other),
        .init(nameKey: "food.other.protein_powder", unit: "g",    defaultAmount: 30,  category: .other),
    ]
}
