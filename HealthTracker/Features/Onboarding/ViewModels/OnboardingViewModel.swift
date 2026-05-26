import Foundation
import Observation

// MARK: - OnboardingViewModel

@MainActor
@Observable
final class OnboardingViewModel {

    // MARK: - Step

    enum Step { case welcome, exerciseSelection }

    // MARK: - State

    var step:              Step                    = .welcome
    var activeStyle:       TrainingStyle           = .gym
    var selectedExercises: Set<OnboardingExercise> = []
    var isSaving           = false
    var errorMessage:      String?

    // MARK: - Catalog

    let catalog = OnboardingExerciseCatalog.all

    // MARK: - Private

    private let seedExercisesUC: any SeedExercisesUseCase
    private let preferencesRepo: any UserPreferencesRepository

    // MARK: - Init

    init(factory: FeatureFactory, startingStep: Step = .welcome) {
        seedExercisesUC = factory.makeSeedExercisesUseCase()
        preferencesRepo = factory.userPreferencesRepository
        step = startingStep
    }

    // MARK: - Computed

    var selectedCount: Int { selectedExercises.count }
    var canComplete:   Bool { !selectedExercises.isEmpty }

    // MARK: - Filtering

    func exercises(for style: TrainingStyle, group: MuscleGroup) -> [OnboardingExercise] {
        catalog.filter { $0.style == style && $0.muscleGroup == group }
    }

    /// Ordered list of muscle groups that have at least one exercise for `style`.
    func subcategories(for style: TrainingStyle) -> [MuscleGroup] {
        MuscleGroup.allCases.filter { group in
            catalog.contains { $0.style == style && $0.muscleGroup == group }
        }
    }

    // MARK: - Selection

    func isSelected(_ exercise: OnboardingExercise) -> Bool {
        selectedExercises.contains(exercise)
    }

    func toggle(_ exercise: OnboardingExercise) {
        if selectedExercises.contains(exercise) {
            selectedExercises.remove(exercise)
        } else {
            selectedExercises.insert(exercise)
        }
    }

    func selectAll(for style: TrainingStyle) {
        catalog.filter { $0.style == style }.forEach { selectedExercises.insert($0) }
    }

    func deselectAll(for style: TrainingStyle) {
        catalog.filter { $0.style == style }.forEach { selectedExercises.remove($0) }
    }

    func isAllSelected(for style: TrainingStyle) -> Bool {
        let styleItems = catalog.filter { $0.style == style }
        return !styleItems.isEmpty && styleItems.allSatisfy { selectedExercises.contains($0) }
    }

    // MARK: - Navigation

    func goToExerciseSelection() {
        step = .exerciseSelection
    }

    // MARK: - Completion

    /// Saves selected exercises and marks onboarding as complete.
    /// Returns `true` on success.
    func completeOnboarding() async -> Bool {
        guard !isSaving else { return false }
        isSaving = true
        defer { isSaving = false }
        do {
            let exercises = selectedExercises.map { $0.toDomainExercise() }
            try await seedExercisesUC.execute(exercises)
            preferencesRepo.setHasCompletedOnboarding(true)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// Skips exercise selection but still marks onboarding as done.
    func skipOnboarding() {
        preferencesRepo.setHasCompletedOnboarding(true)
    }
}
