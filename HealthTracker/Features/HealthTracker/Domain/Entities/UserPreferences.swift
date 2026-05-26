import Foundation

// MARK: - UserPreferences
// Persistent user-level settings and health profile.
// Uses a fully custom Codable init so adding new fields never breaks
// existing stored JSON (all new keys decoded with decodeIfPresent).

struct UserPreferences: Codable, Equatable {

    // MARK: - Measurements

    var hydrationUnit: HydrationUnit
    var preferredWeightUnit: WeightUnit

    // MARK: - Personal profile

    var name: String?
    var biologicalSex: BiologicalSex?
    var birthYear: Int?

    // MARK: - Body metrics

    var heightCm: Double?
    var weightKg: Double?
    var bodyFatPercent: Double?

    // MARK: - Health

    var chronicConditions: [ChronicCondition]
    var medications: String?

    // MARK: - Goals

    var fitnessGoals: [FitnessGoal]
    var trainingDaysPerWeek: Int?

    // MARK: - Default

    static var deviceDefault: UserPreferences {
        UserPreferences(hydrationUnit: .deviceDefault)
    }

    // MARK: - Init

    init(
        hydrationUnit:       HydrationUnit    = .deviceDefault,
        preferredWeightUnit: WeightUnit       = .kg,
        name:                String?          = nil,
        biologicalSex:       BiologicalSex?   = nil,
        birthYear:           Int?             = nil,
        heightCm:            Double?          = nil,
        weightKg:            Double?          = nil,
        bodyFatPercent:      Double?          = nil,
        chronicConditions:   [ChronicCondition] = [],
        medications:         String?          = nil,
        fitnessGoals:        [FitnessGoal]    = [],
        trainingDaysPerWeek: Int?             = nil
    ) {
        self.hydrationUnit       = hydrationUnit
        self.preferredWeightUnit = preferredWeightUnit
        self.name                = name
        self.biologicalSex       = biologicalSex
        self.birthYear           = birthYear
        self.heightCm            = heightCm
        self.weightKg            = weightKg
        self.bodyFatPercent      = bodyFatPercent
        self.chronicConditions   = chronicConditions
        self.medications         = medications
        self.fitnessGoals        = fitnessGoals
        self.trainingDaysPerWeek = trainingDaysPerWeek
    }

    // MARK: - Codable (backward-compatible custom decoder)

    enum CodingKeys: String, CodingKey {
        case hydrationUnit, preferredWeightUnit
        case name, biologicalSex, birthYear
        case heightCm, weightKg, bodyFatPercent
        case chronicConditions, medications
        case fitnessGoals, trainingDaysPerWeek
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        hydrationUnit       = try c.decodeIfPresent(HydrationUnit.self,         forKey: .hydrationUnit)       ?? .deviceDefault
        preferredWeightUnit = try c.decodeIfPresent(WeightUnit.self,            forKey: .preferredWeightUnit) ?? .kg
        name                = try c.decodeIfPresent(String.self,                forKey: .name)
        biologicalSex       = try c.decodeIfPresent(BiologicalSex.self,         forKey: .biologicalSex)
        birthYear           = try c.decodeIfPresent(Int.self,                   forKey: .birthYear)
        heightCm            = try c.decodeIfPresent(Double.self,                forKey: .heightCm)
        weightKg            = try c.decodeIfPresent(Double.self,                forKey: .weightKg)
        bodyFatPercent      = try c.decodeIfPresent(Double.self,                forKey: .bodyFatPercent)
        chronicConditions   = try c.decodeIfPresent([ChronicCondition].self,    forKey: .chronicConditions)   ?? []
        medications         = try c.decodeIfPresent(String.self,                forKey: .medications)
        fitnessGoals        = try c.decodeIfPresent([FitnessGoal].self,         forKey: .fitnessGoals)        ?? []
        trainingDaysPerWeek = try c.decodeIfPresent(Int.self,                   forKey: .trainingDaysPerWeek)
    }
}
