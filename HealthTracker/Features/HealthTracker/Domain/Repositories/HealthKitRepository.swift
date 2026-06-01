import Foundation

// MARK: - HealthKitRepository
// Read-only access to Apple Health data.
// isAvailable returns false on unsupported hardware; all methods are no-ops in that case.

protocol HealthKitRepository {
    var isAvailable: Bool { get }
    func requestAuthorization() async throws
    func fetchTodaySteps() async throws -> Int?
    func fetchTodayWorkouts() async throws -> [HealthKitWorkout]
    func fetchLastNightSleep() async throws -> Double?
}
