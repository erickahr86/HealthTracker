import Foundation

// MARK: - ExerciseMapper

enum ExerciseMapper {

    static func toDomain(_ model: ExerciseModel) -> Exercise {
        Exercise(
            id: model.id,
            name: model.name,
            defaultWeight: model.defaultWeight,
            weightUnit: WeightUnit(rawValue: model.weightUnitRaw) ?? .kg,
            muscleGroup: MuscleGroup(rawValue: model.muscleGroupRaw) ?? .superior,
            isCustom: model.isCustom
        )
    }

    static func toModel(_ entity: Exercise) -> ExerciseModel {
        ExerciseModel(
            id: entity.id,
            name: entity.name,
            defaultWeight: entity.defaultWeight,
            weightUnitRaw: entity.weightUnit.rawValue,
            muscleGroupRaw: entity.muscleGroup.rawValue,
            isCustom: entity.isCustom
        )
    }
}

// MARK: - ExerciseLogMapper

enum ExerciseLogMapper {

    static func toDomain(_ model: ExerciseLogModel) -> ExerciseLog? {
        guard let exerciseModel = model.exercise else { return nil }
        return ExerciseLog(
            id: model.id,
            exercise: ExerciseMapper.toDomain(exerciseModel),
            weight: model.weight,
            weightUnit: WeightUnit(rawValue: model.weightUnitRaw) ?? .kg
        )
    }

    static func toModel(_ entity: ExerciseLog) -> ExerciseLogModel {
        ExerciseLogModel(
            id: entity.id,
            weight: entity.weight,
            weightUnitRaw: entity.weightUnit.rawValue,
            exercise: ExerciseMapper.toModel(entity.exercise)
        )
    }
}
