import Foundation

// MARK: - HealthKitWorkout

struct HealthKitWorkout: Identifiable, Hashable {
    let id: UUID
    let name: String
    let durationMinutes: Int
    let calories: Int?
}
