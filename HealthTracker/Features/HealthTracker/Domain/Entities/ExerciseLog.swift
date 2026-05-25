import Foundation

// MARK: - ExerciseLog

struct ExerciseLog: Identifiable, Hashable {
    let id: UUID
    var exercise: Exercise
    var weight: Double
    var weightUnit: WeightUnit

    init(
        id: UUID = UUID(),
        exercise: Exercise,
        weight: Double,
        weightUnit: WeightUnit = .kg
    ) {
        self.id = id
        self.exercise = exercise
        self.weight = weight
        self.weightUnit = weightUnit
    }
}
