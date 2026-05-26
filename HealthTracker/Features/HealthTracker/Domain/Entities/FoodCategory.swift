import Foundation

// MARK: - FoodCategory
// Groups foods into logical sections for the picker and catalog.
// Custom foods added by the user have category = nil (shown under "Other").

enum FoodCategory: String, Codable, CaseIterable, Hashable {
    case protein
    case grains
    case vegetables
    case fruits
    case dairy
    case legumes
    case other

    var displayName: String {
        NSLocalizedString("food.category.\(rawValue)", comment: "Food category name")
    }

    var systemImage: String {
        switch self {
        case .protein:    return "fork.knife"
        case .grains:     return "square.stack.fill"
        case .vegetables: return "leaf.fill"
        case .fruits:     return "circle.hexagonpath.fill"
        case .dairy:      return "cup.and.saucer.fill"
        case .legumes:    return "circle.grid.3x3.fill"
        case .other:      return "ellipsis.circle.fill"
        }
    }
}
