import Foundation
import SwiftData

// MARK: - ExerciseModel

@Model
final class ExerciseModel {

    var id: UUID
    var name: String
    var defaultWeight: Double
    var weightUnitRaw: String      // WeightUnit.rawValue
    var muscleGroupRaw: String     // MuscleGroup.rawValue
    var isCustom: Bool

    @Relationship(deleteRule: .nullify, inverse: \ExerciseLogModel.exercise)
    var logs: [ExerciseLogModel]

    init(
        id: UUID = UUID(),
        name: String,
        defaultWeight: Double,
        weightUnitRaw: String,
        muscleGroupRaw: String,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.defaultWeight = defaultWeight
        self.weightUnitRaw = weightUnitRaw
        self.muscleGroupRaw = muscleGroupRaw
        self.isCustom = isCustom
        self.logs = []
    }
}
