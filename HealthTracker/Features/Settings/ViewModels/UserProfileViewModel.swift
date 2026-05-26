import Foundation

// MARK: - UserProfileViewModel

@MainActor
@Observable
final class UserProfileViewModel {

    // MARK: - State

    var preferences: UserPreferences
    var isSaved = false

    // MARK: - Private

    private let repository: any UserPreferencesRepository

    // MARK: - Init

    init(repository: any UserPreferencesRepository) {
        self.repository  = repository
        self.preferences = repository.get()
    }

    // MARK: - Actions

    func save() {
        repository.save(preferences)
        isSaved = true
    }

    func toggleCondition(_ condition: ChronicCondition) {
        if preferences.chronicConditions.contains(condition) {
            preferences.chronicConditions.removeAll { $0 == condition }
        } else {
            preferences.chronicConditions.append(condition)
        }
    }

    func toggleGoal(_ goal: FitnessGoal) {
        if preferences.fitnessGoals.contains(goal) {
            preferences.fitnessGoals.removeAll { $0 == goal }
        } else {
            preferences.fitnessGoals.append(goal)
        }
    }

    // MARK: - Computed

    /// Age derived from the stored birth year, or nil if not set.
    var computedAge: Int? {
        guard let year = preferences.birthYear else { return nil }
        return Calendar.current.component(.year, from: Date()) - year
    }
}
