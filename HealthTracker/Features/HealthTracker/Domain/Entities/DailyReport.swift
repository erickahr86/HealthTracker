import Foundation

// MARK: - TrafficLight

enum TrafficLight: String, Codable, Hashable {
    case green
    case yellow
    case red
}

// MARK: - DailyReport

struct DailyReport: Identifiable, Hashable {
    let id: UUID
    var date: Date
    var isRestDay: Bool
    var steps: Int?

    var exerciseLogs: [ExerciseLog]
    var mealLogs: [MealLog]

    var waterGlasses: Int

    var energyLevel: Int?
    var sleepHours: String?
    var glucoseMgdl: Int?
    var bloodPressure: String?
    var notes: String?

    var analysisResult: String?
    var analysisDate: Date?
    var trafficLight: TrafficLight?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        isRestDay: Bool = false,
        steps: Int? = nil,
        exerciseLogs: [ExerciseLog] = [],
        mealLogs: [MealLog] = [],
        waterGlasses: Int = 0,
        energyLevel: Int? = nil,
        sleepHours: String? = nil,
        glucoseMgdl: Int? = nil,
        bloodPressure: String? = nil,
        notes: String? = nil,
        analysisResult: String? = nil,
        analysisDate: Date? = nil,
        trafficLight: TrafficLight? = nil
    ) {
        self.id = id
        self.date = date
        self.isRestDay = isRestDay
        self.steps = steps
        self.exerciseLogs = exerciseLogs
        self.mealLogs = mealLogs
        self.waterGlasses = waterGlasses
        self.energyLevel = energyLevel
        self.sleepHours = sleepHours
        self.glucoseMgdl = glucoseMgdl
        self.bloodPressure = bloodPressure
        self.notes = notes
        self.analysisResult = analysisResult
        self.analysisDate = analysisDate
        self.trafficLight = trafficLight
    }
}
