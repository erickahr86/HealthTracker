import Foundation

// MARK: - DailyReportMapper

enum DailyReportMapper {

    static func toDomain(_ model: DailyReportModel) -> DailyReport {
        DailyReport(
            id: model.id,
            date: model.date,
            isRestDay: model.isRestDay,
            steps: model.steps,
            exerciseLogs: model.exerciseLogs.compactMap { ExerciseLogMapper.toDomain($0) },
            mealLogs: model.mealLogs.map { MealLogMapper.toDomain($0) },
            waterGlasses: model.waterGlasses,
            energyLevel: model.energyLevel,
            sleepHours: model.sleepHours,
            glucoseMgdl: model.glucoseMgdl,
            bloodPressure: model.bloodPressure,
            notes: model.notes,
            analysisResult: model.analysisResult,
            analysisDate: model.analysisDate,
            trafficLight: model.trafficLightRaw.flatMap { TrafficLight(rawValue: $0) }
        )
    }

    static func toModel(_ entity: DailyReport) -> DailyReportModel {
        let model = DailyReportModel(
            id: entity.id,
            date: entity.date,
            isRestDay: entity.isRestDay,
            steps: entity.steps,
            waterGlasses: entity.waterGlasses,
            energyLevel: entity.energyLevel,
            sleepHours: entity.sleepHours,
            glucoseMgdl: entity.glucoseMgdl,
            bloodPressure: entity.bloodPressure,
            notes: entity.notes,
            analysisResult: entity.analysisResult,
            analysisDate: entity.analysisDate,
            trafficLightRaw: entity.trafficLight?.rawValue
        )
        model.exerciseLogs = entity.exerciseLogs.map { ExerciseLogMapper.toModel($0) }
        model.mealLogs = entity.mealLogs.map { MealLogMapper.toModel($0) }
        return model
    }
}
