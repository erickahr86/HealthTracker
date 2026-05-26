import Foundation

// MARK: - FitnessGoal

enum FitnessGoal: String, Codable, CaseIterable, Hashable {
    case weightLoss
    case muscleGain
    case improveCardio
    case longevity
    case improveMobility
    case improveStrength
    case manageBloodSugar
    case lowerBloodPressure
    case generalHealth
    case athleticPerformance

    var displayName: String {
        NSLocalizedString("goal.\(rawValue)", comment: "Fitness goal label")
    }
}
