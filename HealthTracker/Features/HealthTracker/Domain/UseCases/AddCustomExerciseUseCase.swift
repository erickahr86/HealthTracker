import Foundation

// MARK: - Protocol

protocol AddCustomExerciseUseCase {
    func execute(name: String, defaultWeight: Double, weightUnit: WeightUnit, muscleGroup: MuscleGroup) async throws -> Exercise
}

// MARK: - Implementation

final class AddCustomExerciseUseCaseImpl: AddCustomExerciseUseCase {

    private let exerciseRepository: ExerciseRepository

    init(exerciseRepository: ExerciseRepository) {
        self.exerciseRepository = exerciseRepository
    }

    func execute(name: String, defaultWeight: Double, weightUnit: WeightUnit, muscleGroup: MuscleGroup) async throws -> Exercise {
        let exercise = Exercise(
            name: name,
            defaultWeight: defaultWeight,
            weightUnit: weightUnit,
            muscleGroup: muscleGroup,
            isCustom: true
        )
        try await exerciseRepository.save(exercise)
        return exercise
    }
}
