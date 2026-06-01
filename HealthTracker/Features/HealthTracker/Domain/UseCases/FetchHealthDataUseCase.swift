import Foundation

// MARK: - HealthData

struct HealthData {
    let steps: Int?
    let workouts: [HealthKitWorkout]
    let sleepHours: Double?
}

// MARK: - Protocol

protocol FetchHealthDataUseCase {
    var isAvailable: Bool { get }
    func execute() async throws -> HealthData
}

// MARK: - Implementation

final class FetchHealthDataUseCaseImpl: FetchHealthDataUseCase {

    private let healthKitRepository: any HealthKitRepository

    init(healthKitRepository: any HealthKitRepository) {
        self.healthKitRepository = healthKitRepository
    }

    var isAvailable: Bool { healthKitRepository.isAvailable }

    func execute() async throws -> HealthData {
        try await healthKitRepository.requestAuthorization()
        async let steps    = healthKitRepository.fetchTodaySteps()
        async let workouts = healthKitRepository.fetchTodayWorkouts()
        async let sleep    = healthKitRepository.fetchLastNightSleep()
        return try await HealthData(steps: steps, workouts: workouts, sleepHours: sleep)
    }
}
