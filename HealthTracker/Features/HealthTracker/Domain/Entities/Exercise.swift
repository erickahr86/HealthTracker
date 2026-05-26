import Foundation

// MARK: - MuscleGroup

enum MuscleGroup: String, Codable, CaseIterable, Hashable {
    case superior
    case inferior
    case fullBody   // Cardio and full-body exercises

    var displayName: String {
        NSLocalizedString("muscle.group.\(rawValue)", comment: "Muscle group display name")
    }
}

// MARK: - WeightUnit

enum WeightUnit: String, Codable, CaseIterable, Hashable {
    case kg
    case lbs

    var displayName: String {
        switch self {
        case .kg:  return "kg"
        case .lbs: return "lbs"
        }
    }

    func convert(_ value: Double, to target: WeightUnit) -> Double {
        guard self != target else { return value }
        switch (self, target) {
        case (.kg, .lbs):  return value * 2.20462
        case (.lbs, .kg):  return value / 2.20462
        default:           return value
        }
    }
}

// MARK: - Exercise

struct Exercise: Identifiable, Hashable {
    let id: UUID
    var name: String
    var defaultWeight: Double
    var weightUnit: WeightUnit
    var muscleGroup: MuscleGroup
    var isCustom: Bool

    init(
        id: UUID = UUID(),
        name: String,
        defaultWeight: Double,
        weightUnit: WeightUnit = .kg,
        muscleGroup: MuscleGroup,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.defaultWeight = defaultWeight
        self.weightUnit = weightUnit
        self.muscleGroup = muscleGroup
        self.isCustom = isCustom
    }
}
