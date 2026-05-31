import Foundation

// MARK: - UserPreferencesRepository
// Stores and retrieves user-level preferences (hydration unit, future profile fields).
// Implementations are expected to persist via UserDefaults.
// Operations are synchronous — no I/O overhead for simple key-value data.

protocol UserPreferencesRepository {

    // MARK: - Whole object

    func get() -> UserPreferences
    func save(_ preferences: UserPreferences)

    // MARK: - Convenience accessors

    func getHydrationUnit() -> HydrationUnit
    func setHydrationUnit(_ unit: HydrationUnit)

    // MARK: - Onboarding

    func hasCompletedOnboarding() -> Bool
    func setHasCompletedOnboarding(_ value: Bool)

    // MARK: - Seed flags

    func hasSeedInitialFoods() -> Bool
    func setHasSeedInitialFoods(_ value: Bool)
}
