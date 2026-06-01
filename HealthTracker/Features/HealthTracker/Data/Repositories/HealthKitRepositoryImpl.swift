import Foundation
import HealthKit

// MARK: - HealthKitRepositoryImpl

final class HealthKitRepositoryImpl: HealthKitRepository {

    private let service = HealthKitService()

    var isAvailable: Bool { HealthKitService.isAvailable }

    func requestAuthorization() async throws {
        try await service.requestAuthorization()
    }

    func fetchTodaySteps() async throws -> Int? {
        try await service.fetchTodaySteps()
    }

    func fetchTodayWorkouts() async throws -> [HealthKitWorkout] {
        try await service.fetchTodayWorkouts().map { workout in
            HealthKitWorkout(
                id: workout.uuid,
                name: workout.workoutActivityType.displayName,
                durationMinutes: Int(workout.duration / 60),
                calories: workout.statistics(for: HKQuantityType(.activeEnergyBurned))
                    .flatMap { $0.sumQuantity() }
                    .map { Int($0.doubleValue(for: .kilocalorie())) }
            )
        }
    }

    func fetchLastNightSleep() async throws -> Double? {
        try await service.fetchLastNightSleep()
    }
}

// MARK: - HKWorkoutActivityType + displayName

private extension HKWorkoutActivityType {
    var displayName: String {
        switch self {
        case .traditionalStrengthTraining:    return "Strength Training"
        case .functionalStrengthTraining:     return "Functional Training"
        case .highIntensityIntervalTraining:  return "HIIT"
        case .crossTraining:                  return "Cross Training"
        case .coreTraining:                   return "Core Training"
        case .flexibility:                    return "Flexibility"
        case .walking:                        return "Walking"
        case .running:                        return "Running"
        case .cycling:                        return "Cycling"
        case .swimming:                       return "Swimming"
        case .yoga:                           return "Yoga"
        case .pilates:                        return "Pilates"
        case .dance:                          return "Dance"
        case .hiking:                         return "Hiking"
        case .rowing:                         return "Rowing"
        case .elliptical:                     return "Elliptical"
        case .stairClimbing:                  return "Stair Climbing"
        case .jumpRope:                       return "Jump Rope"
        case .boxing:                         return "Boxing"
        case .mindAndBody:                    return "Mind & Body"
        case .mixedCardio:                    return "Mixed Cardio"
        case .preparationAndRecovery:         return "Recovery"
        case .soccer:                         return "Soccer"
        case .basketball:                     return "Basketball"
        case .tennis:                         return "Tennis"
        case .martialArts:                    return "Martial Arts"
        case .other:                          return "Workout"
        default:                              return "Workout"
        }
    }
}
