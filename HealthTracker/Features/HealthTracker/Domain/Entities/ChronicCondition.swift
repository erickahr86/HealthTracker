import Foundation

// MARK: - ChronicCondition

enum ChronicCondition: String, Codable, CaseIterable, Hashable {
    case type2Diabetes
    case type1Diabetes
    case hypertension
    case highTriglycerides
    case fattyLiver
    case renalDisease
    case hypothyroidism
    case obesity
    case insulinResistance
    case highCholesterol
    case heartDisease
    case asthma
    case arthritis

    var displayName: String {
        NSLocalizedString("condition.\(rawValue)", comment: "Chronic condition label")
    }
}
