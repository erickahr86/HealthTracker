import Foundation
import SwiftData

// MARK: - DailyReportModel

@Model
final class DailyReportModel {

    var id: UUID
    var date: Date
    var isRestDay: Bool
    var steps: Int?
    var waterGlasses: Int

    var energyLevel: Int?
    var sleepHours: String?
    var glucoseMgdl: Int?
    var bloodPressure: String?
    var notes: String?

    var analysisResult: String?
    var analysisDate: Date?
    var trafficLightRaw: String?   // TrafficLight.rawValue

    @Relationship(deleteRule: .cascade, inverse: \ExerciseLogModel.report)
    var exerciseLogs: [ExerciseLogModel]

    @Relationship(deleteRule: .cascade, inverse: \MealLogModel.report)
    var mealLogs: [MealLogModel]

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        isRestDay: Bool = false,
        steps: Int? = nil,
        waterGlasses: Int = 0,
        energyLevel: Int? = nil,
        sleepHours: String? = nil,
        glucoseMgdl: Int? = nil,
        bloodPressure: String? = nil,
        notes: String? = nil,
        analysisResult: String? = nil,
        analysisDate: Date? = nil,
        trafficLightRaw: String? = nil
    ) {
        self.id = id
        self.date = date
        self.isRestDay = isRestDay
        self.steps = steps
        self.waterGlasses = waterGlasses
        self.energyLevel = energyLevel
        self.sleepHours = sleepHours
        self.glucoseMgdl = glucoseMgdl
        self.bloodPressure = bloodPressure
        self.notes = notes
        self.analysisResult = analysisResult
        self.analysisDate = analysisDate
        self.trafficLightRaw = trafficLightRaw
        self.exerciseLogs = []
        self.mealLogs = []
    }
}
