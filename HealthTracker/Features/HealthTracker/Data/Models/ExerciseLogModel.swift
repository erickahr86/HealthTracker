import Foundation
import SwiftData

// MARK: - ExerciseLogModel

@Model
final class ExerciseLogModel {

    var id: UUID
    var weight: Double
    var weightUnitRaw: String      // WeightUnit.rawValue

    var exercise: ExerciseModel?
    var report: DailyReportModel?

    init(
        id: UUID = UUID(),
        weight: Double,
        weightUnitRaw: String,
        exercise: ExerciseModel? = nil,
        report: DailyReportModel? = nil
    ) {
        self.id = id
        self.weight = weight
        self.weightUnitRaw = weightUnitRaw
        self.exercise = exercise
        self.report = report
    }
}
