import Foundation
import HealthKit

// MARK: - HealthKitService
// Wraps HKHealthStore. All methods are safe to call when HealthKit is unavailable —
// they return early without error. Auth dialog shows once; subsequent calls are no-ops.

final class HealthKitService {

    private let store = HKHealthStore()

    static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    // MARK: - Authorization

    func requestAuthorization() async throws {
        guard Self.isAvailable else { return }
        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKObjectType.workoutType(),
            HKCategoryType(.sleepAnalysis)
        ]
        try await store.requestAuthorization(toShare: [], read: readTypes)
    }

    // MARK: - Steps

    func fetchTodaySteps() async throws -> Int? {
        guard Self.isAvailable else { return nil }
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: HKQuantityType(.stepCount),
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, error in
                if let error { continuation.resume(throwing: error); return }
                let steps = stats?.sumQuantity().map { Int($0.doubleValue(for: .count())) }
                continuation.resume(returning: steps ?? nil)
            }
            store.execute(query)
        }
    }

    // MARK: - Workouts

    func fetchTodayWorkouts() async throws -> [HKWorkout] {
        guard Self.isAvailable else { return [] }
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume(returning: (samples as? [HKWorkout]) ?? [])
            }
            store.execute(query)
        }
    }

    // MARK: - Sleep

    func fetchLastNightSleep() async throws -> Double? {
        guard Self.isAvailable else { return nil }
        let end   = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -10, to: end) ?? end
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKCategoryType(.sleepAnalysis),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error { continuation.resume(throwing: error); return }
                let totalSeconds = (samples as? [HKCategorySample])?.reduce(0.0) { acc, sample in
                    switch HKCategoryValueSleepAnalysis(rawValue: sample.value) {
                    case .asleepUnspecified, .asleepCore, .asleepDeep, .asleepREM:
                        return acc + sample.endDate.timeIntervalSince(sample.startDate)
                    default:
                        return acc
                    }
                } ?? 0
                continuation.resume(returning: totalSeconds > 0 ? totalSeconds / 3600 : nil)
            }
            store.execute(query)
        }
    }
}
