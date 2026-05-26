import Foundation

// MARK: - CatalogTab

enum CatalogTab: Hashable {
    case exercises
    case foods
}

// MARK: - CatalogViewModel

@MainActor @Observable
final class CatalogViewModel {

    // MARK: - State

    var selectedTab: CatalogTab  = .exercises
    var exercises:   [Exercise]  = []
    var foods:       [Food]      = []
    var isLoading                = false
    var errorMessage: String?    = nil

    // MARK: - Computed: grouped data

    /// Exercises grouped by muscle group, in enum order, sorted alphabetically within each group.
    var exercisesByGroup: [(MuscleGroup, [Exercise])] {
        var grouped: [MuscleGroup: [Exercise]] = [:]
        for e in exercises {
            grouped[e.muscleGroup, default: []].append(e)
        }
        return MuscleGroup.allCases.compactMap { group in
            guard let items = grouped[group], !items.isEmpty else { return nil }
            return (group, items.sorted {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            })
        }
    }

    /// Foods grouped by category (enum order), custom foods (nil category) at the end.
    var foodsByCategory: [(FoodCategory?, [Food])] {
        var grouped: [FoodCategory?: [Food]] = [:]
        for f in foods {
            grouped[f.category, default: []].append(f)
        }
        let sortedKeys: [FoodCategory?] = FoodCategory.allCases.map { Optional($0) } + [nil]
        return sortedKeys.compactMap { cat in
            guard let items = grouped[cat], !items.isEmpty else { return nil }
            return (cat, items.sorted {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            })
        }
    }

    // MARK: - Dependencies

    private let getExercisesUseCase:      any GetExercisesUseCase
    private let getFoodsUseCase:          any GetFoodsUseCase
    private let addCustomExerciseUseCase: any AddCustomExerciseUseCase
    private let addCustomFoodUseCase:     any AddCustomFoodUseCase
    private let exerciseRepository:       any ExerciseRepository
    private let foodRepository:           any FoodRepository

    // MARK: - Init

    init(
        factory:            FeatureFactory,
        exerciseRepository: any ExerciseRepository,
        foodRepository:     any FoodRepository
    ) {
        self.getExercisesUseCase      = factory.makeGetExercisesUseCase()
        self.getFoodsUseCase          = factory.makeGetFoodsUseCase()
        self.addCustomExerciseUseCase = factory.makeAddCustomExerciseUseCase()
        self.addCustomFoodUseCase     = factory.makeAddCustomFoodUseCase()
        self.exerciseRepository       = exerciseRepository
        self.foodRepository           = foodRepository
    }

    // MARK: - Load

    func loadAll() async {
        isLoading = true
        defer { isLoading = false }
        await loadExercises()
        await loadFoods()
    }

    private func loadExercises() async {
        do {
            exercises = try await getExercisesUseCase.execute(filter: nil)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadFoods() async {
        do {
            foods = try await getFoodsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Exercise actions

    func addExercise(
        name:          String,
        defaultWeight: Double,
        weightUnit:    WeightUnit,
        muscleGroup:   MuscleGroup
    ) async {
        do {
            let exercise = try await addCustomExerciseUseCase.execute(
                name:          name,
                defaultWeight: defaultWeight,
                weightUnit:    weightUnit,
                muscleGroup:   muscleGroup
            )
            exercises.append(exercise)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteExercise(_ exercise: Exercise) async {
        guard exercise.isCustom else { return }
        do {
            try await exerciseRepository.delete(exercise)
            exercises.removeAll { $0.id == exercise.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Food actions

    func addFood(name: String, unit: String, defaultAmount: Double) async {
        do {
            let food = try await addCustomFoodUseCase.execute(
                name:          name,
                unit:          unit,
                defaultAmount: defaultAmount
            )
            foods.append(food)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteFood(_ food: Food) async {
        guard food.isCustom else { return }
        do {
            try await foodRepository.delete(food)
            foods.removeAll { $0.id == food.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
