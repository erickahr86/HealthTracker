import Foundation

// MARK: - UserPreferences
// Persistent user-level settings.
// Designed to grow: hydration unit today; weight unit, age, health
// conditions, goals, etc. will be added here to feed the AI prompt dynamically.

struct UserPreferences: Codable, Equatable {

    // MARK: - Hydration

    var hydrationUnit: HydrationUnit

    // MARK: - Future fields (uncomment as each section is built)
    //
    // Personal profile — used to personalise the AI system prompt:
    // var weightKg:            Double?
    // var heightCm:            Double?
    // var birthYear:           Int?
    // var biologicalSex:       BiologicalSex?
    // var chronicConditions:   [String]
    // var medications:         [String]
    // var fitnessGoals:        [String]
    // var preferredWeightUnit: WeightUnit

    // MARK: - Default

    /// Returns preferences initialised from the device's locale / settings.
    static var deviceDefault: UserPreferences {
        UserPreferences(hydrationUnit: .deviceDefault)
    }

    // MARK: - Init

    init(hydrationUnit: HydrationUnit = .deviceDefault) {
        self.hydrationUnit = hydrationUnit
    }
}
