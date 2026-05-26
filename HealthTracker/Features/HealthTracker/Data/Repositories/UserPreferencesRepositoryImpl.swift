import Foundation

// MARK: - UserPreferencesRepositoryImpl
// Persists UserPreferences as JSON in UserDefaults.
// Falls back to device-locale defaults when no value is stored yet.

final class UserPreferencesRepositoryImpl: UserPreferencesRepository {

    // MARK: - Private

    private let defaults: UserDefaults
    private let storageKey      = "ht.user_preferences"
    private let onboardingKey   = "ht.has_completed_onboarding"
    private let encoder         = JSONEncoder()
    private let decoder         = JSONDecoder()

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - UserPreferencesRepository

    func get() -> UserPreferences {
        guard
            let data  = defaults.data(forKey: storageKey),
            let prefs = try? decoder.decode(UserPreferences.self, from: data)
        else {
            return .deviceDefault
        }
        return prefs
    }

    func save(_ preferences: UserPreferences) {
        guard let data = try? encoder.encode(preferences) else { return }
        defaults.set(data, forKey: storageKey)
    }

    // MARK: - Convenience

    func getHydrationUnit() -> HydrationUnit {
        get().hydrationUnit
    }

    func setHydrationUnit(_ unit: HydrationUnit) {
        var prefs = get()
        prefs.hydrationUnit = unit
        save(prefs)
    }

    // MARK: - Onboarding

    func hasCompletedOnboarding() -> Bool {
        defaults.bool(forKey: onboardingKey)
    }

    func setHasCompletedOnboarding(_ value: Bool) {
        defaults.set(value, forKey: onboardingKey)
    }
}
