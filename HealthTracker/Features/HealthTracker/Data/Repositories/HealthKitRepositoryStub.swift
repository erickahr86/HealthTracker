import Foundation

// MARK: - HealthKitRepositoryStub
// Used in SwiftUI Previews and in-memory containers where HealthKit is unavailable.

struct HealthKitRepositoryStub: HealthKitRepository {
    var isAvailable: Bool { false }
    func requestAuthorization() async throws {}
    func fetchTodaySteps() async throws -> Int? { nil }
    func fetchTodayWorkouts() async throws -> [HealthKitWorkout] { [] }
    func fetchLastNightSleep() async throws -> Double? { nil }
}
