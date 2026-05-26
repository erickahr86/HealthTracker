import Foundation

// MARK: - TrainingStyle
// User-facing training methodology. Used only during onboarding to group
// the exercise catalog into meaningful sections. Not persisted.

enum TrainingStyle: String, CaseIterable, Hashable {
    case gym          = "gym"
    case calisthenics = "calisthenics"
    case pilates      = "pilates"
    case crossfit     = "crossfit"
    case others       = "others"

    var displayName: String {
        NSLocalizedString("training.style.\(rawValue)", comment: "Training style name")
    }

    var systemImage: String {
        switch self {
        case .gym:          return "dumbbell"
        case .calisthenics: return "figure.strengthtraining.traditional"
        case .pilates:      return "figure.flexibility"
        case .crossfit:     return "bolt.fill"
        case .others:       return "figure.walk"
        }
    }
}

// MARK: - OnboardingExercise
// A catalog entry used exclusively in the onboarding wizard.
// The `nameKey` maps to Localizable.strings (EN + ES) so the UI automatically
// shows the correct language. The `name` computed property resolves it at
// read time, which means `toDomainExercise()` persists the user's locale.

struct OnboardingExercise: Identifiable, Hashable {

    let id:            UUID          // stable within process (static catalog)
    let nameKey:       String        // Localizable.strings key
    let muscleGroup:   MuscleGroup
    let defaultWeight: Double
    let weightUnit:    WeightUnit
    let style:         TrainingStyle

    var name: String {
        NSLocalizedString(nameKey, comment: "Exercise name")
    }

    // MARK: - Init

    init(
        nameKey:       String,
        muscleGroup:   MuscleGroup,
        defaultWeight: Double = 0,
        weightUnit:    WeightUnit = .kg,
        style:         TrainingStyle
    ) {
        self.id            = UUID()   // lazily unique; catalog is `static let`
        self.nameKey       = nameKey
        self.muscleGroup   = muscleGroup
        self.defaultWeight = defaultWeight
        self.weightUnit    = weightUnit
        self.style         = style
    }

    // MARK: - Domain conversion

    /// Converts to a domain Exercise using the currently active locale.
    func toDomainExercise() -> Exercise {
        Exercise(
            id:            UUID(),
            name:          name,          // localized at the moment of saving
            defaultWeight: defaultWeight,
            weightUnit:    weightUnit,
            muscleGroup:   muscleGroup,
            isCustom:      false
        )
    }

    // MARK: - Hashable

    static func == (lhs: OnboardingExercise, rhs: OnboardingExercise) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - OnboardingExerciseCatalog
// 75 exercises: 5 training styles × 3 muscle groups × 5 exercises.
// Add new entries here; the UI reads them automatically.

enum OnboardingExerciseCatalog {

    static let all: [OnboardingExercise] = gym + calisthenics + pilates + crossfit + others

    // MARK: Gym (15)

    static let gym: [OnboardingExercise] = [
        // Upper body
        .init(nameKey: "exercise.gym.bench_press",      muscleGroup: .superior, defaultWeight:  60, style: .gym),
        .init(nameKey: "exercise.gym.military_press",   muscleGroup: .superior, defaultWeight:  40, style: .gym),
        .init(nameKey: "exercise.gym.barbell_row",      muscleGroup: .superior, defaultWeight:  50, style: .gym),
        .init(nameKey: "exercise.gym.lat_pulldown",     muscleGroup: .superior, defaultWeight:  45, style: .gym),
        .init(nameKey: "exercise.gym.parallel_dips",    muscleGroup: .superior, defaultWeight:   0, style: .gym),
        // Lower body
        .init(nameKey: "exercise.gym.barbell_squat",    muscleGroup: .inferior, defaultWeight:  80, style: .gym),
        .init(nameKey: "exercise.gym.deadlift",         muscleGroup: .inferior, defaultWeight: 100, style: .gym),
        .init(nameKey: "exercise.gym.leg_press",        muscleGroup: .inferior, defaultWeight: 120, style: .gym),
        .init(nameKey: "exercise.gym.leg_curl",         muscleGroup: .inferior, defaultWeight:  30, style: .gym),
        .init(nameKey: "exercise.gym.leg_extension",    muscleGroup: .inferior, defaultWeight:  25, style: .gym),
        // Cardio / Full body
        .init(nameKey: "exercise.gym.treadmill",        muscleGroup: .fullBody, style: .gym),
        .init(nameKey: "exercise.gym.elliptical",       muscleGroup: .fullBody, style: .gym),
        .init(nameKey: "exercise.gym.rowing_machine",   muscleGroup: .fullBody, style: .gym),
        .init(nameKey: "exercise.gym.battle_ropes",     muscleGroup: .fullBody, style: .gym),
        .init(nameKey: "exercise.gym.stair_climber",    muscleGroup: .fullBody, style: .gym),
    ]

    // MARK: Calisthenics (15)

    static let calisthenics: [OnboardingExercise] = [
        // Upper body
        .init(nameKey: "exercise.cal.push_ups",         muscleGroup: .superior, style: .calisthenics),
        .init(nameKey: "exercise.cal.pull_ups",         muscleGroup: .superior, style: .calisthenics),
        .init(nameKey: "exercise.cal.bar_dips",         muscleGroup: .superior, style: .calisthenics),
        .init(nameKey: "exercise.cal.pike_push_ups",    muscleGroup: .superior, style: .calisthenics),
        .init(nameKey: "exercise.cal.australian_row",   muscleGroup: .superior, style: .calisthenics),
        // Lower body
        .init(nameKey: "exercise.cal.bulgarian_squat",  muscleGroup: .inferior, style: .calisthenics),
        .init(nameKey: "exercise.cal.pistol_squat",     muscleGroup: .inferior, style: .calisthenics),
        .init(nameKey: "exercise.cal.lunges",           muscleGroup: .inferior, style: .calisthenics),
        .init(nameKey: "exercise.cal.step_ups",         muscleGroup: .inferior, style: .calisthenics),
        .init(nameKey: "exercise.cal.glute_bridge",     muscleGroup: .inferior, style: .calisthenics),
        // Cardio / Full body
        .init(nameKey: "exercise.cal.burpees",          muscleGroup: .fullBody, style: .calisthenics),
        .init(nameKey: "exercise.cal.mountain_climbers",muscleGroup: .fullBody, style: .calisthenics),
        .init(nameKey: "exercise.cal.jumping_jacks",    muscleGroup: .fullBody, style: .calisthenics),
        .init(nameKey: "exercise.cal.tuck_jumps",       muscleGroup: .fullBody, style: .calisthenics),
        .init(nameKey: "exercise.cal.bear_crawls",      muscleGroup: .fullBody, style: .calisthenics),
    ]

    // MARK: Pilates (15)

    static let pilates: [OnboardingExercise] = [
        // Upper body
        .init(nameKey: "exercise.pil.front_plank",      muscleGroup: .superior, style: .pilates),
        .init(nameKey: "exercise.pil.side_plank",       muscleGroup: .superior, style: .pilates),
        .init(nameKey: "exercise.pil.roll_up",          muscleGroup: .superior, style: .pilates),
        .init(nameKey: "exercise.pil.teaser",           muscleGroup: .superior, style: .pilates),
        .init(nameKey: "exercise.pil.swan_dive",        muscleGroup: .superior, style: .pilates),
        // Lower body
        .init(nameKey: "exercise.pil.single_leg_stretch", muscleGroup: .inferior, style: .pilates),
        .init(nameKey: "exercise.pil.double_leg_stretch", muscleGroup: .inferior, style: .pilates),
        .init(nameKey: "exercise.pil.clamshell",        muscleGroup: .inferior, style: .pilates),
        .init(nameKey: "exercise.pil.donkey_kicks",     muscleGroup: .inferior, style: .pilates),
        .init(nameKey: "exercise.pil.bridge",           muscleGroup: .inferior, style: .pilates),
        // Cardio / Full body
        .init(nameKey: "exercise.pil.hundred",          muscleGroup: .fullBody, style: .pilates),
        .init(nameKey: "exercise.pil.rolling_ball",     muscleGroup: .fullBody, style: .pilates),
        .init(nameKey: "exercise.pil.criss_cross",      muscleGroup: .fullBody, style: .pilates),
        .init(nameKey: "exercise.pil.swimming",         muscleGroup: .fullBody, style: .pilates),
        .init(nameKey: "exercise.pil.scissors",         muscleGroup: .fullBody, style: .pilates),
    ]

    // MARK: CrossFit (15)

    static let crossfit: [OnboardingExercise] = [
        // Upper body
        .init(nameKey: "exercise.cf.clean_and_press",   muscleGroup: .superior, defaultWeight: 40, style: .crossfit),
        .init(nameKey: "exercise.cf.thruster",          muscleGroup: .superior, defaultWeight: 35, style: .crossfit),
        .init(nameKey: "exercise.cf.push_jerk",         muscleGroup: .superior, defaultWeight: 45, style: .crossfit),
        .init(nameKey: "exercise.cf.snatch",            muscleGroup: .superior, defaultWeight: 30, style: .crossfit),
        .init(nameKey: "exercise.cf.handstand_pushups", muscleGroup: .superior,                    style: .crossfit),
        // Lower body
        .init(nameKey: "exercise.cf.box_jump",          muscleGroup: .inferior,                    style: .crossfit),
        .init(nameKey: "exercise.cf.kettlebell_swing",  muscleGroup: .inferior, defaultWeight: 16, style: .crossfit),
        .init(nameKey: "exercise.cf.goblet_squat",      muscleGroup: .inferior, defaultWeight: 24, style: .crossfit),
        .init(nameKey: "exercise.cf.wall_ball",         muscleGroup: .inferior, defaultWeight:  9, style: .crossfit),
        .init(nameKey: "exercise.cf.jump_squat",        muscleGroup: .inferior,                    style: .crossfit),
        // Cardio / Full body
        .init(nameKey: "exercise.cf.double_unders",     muscleGroup: .fullBody,                    style: .crossfit),
        .init(nameKey: "exercise.cf.row",               muscleGroup: .fullBody,                    style: .crossfit),
        .init(nameKey: "exercise.cf.assault_bike",      muscleGroup: .fullBody,                    style: .crossfit),
        .init(nameKey: "exercise.cf.deadball_carry",    muscleGroup: .fullBody, defaultWeight: 20, style: .crossfit),
        .init(nameKey: "exercise.cf.run_400m",          muscleGroup: .fullBody,                    style: .crossfit),
    ]

    // MARK: Others (15)

    static let others: [OnboardingExercise] = [
        // Upper body
        .init(nameKey: "exercise.ot.trx_rows",             muscleGroup: .superior, style: .others),
        .init(nameKey: "exercise.ot.yoga_arms",            muscleGroup: .superior, style: .others),
        .init(nameKey: "exercise.ot.swimming_freestyle",   muscleGroup: .superior, style: .others),
        .init(nameKey: "exercise.ot.shadow_boxing",        muscleGroup: .superior, style: .others),
        .init(nameKey: "exercise.ot.resistance_band_press",muscleGroup: .superior, style: .others),
        // Lower body
        .init(nameKey: "exercise.ot.cycling",              muscleGroup: .inferior, style: .others),
        .init(nameKey: "exercise.ot.hiking",               muscleGroup: .inferior, style: .others),
        .init(nameKey: "exercise.ot.skating",              muscleGroup: .inferior, style: .others),
        .init(nameKey: "exercise.ot.yoga_warrior",         muscleGroup: .inferior, style: .others),
        .init(nameKey: "exercise.ot.resistance_band_squat",muscleGroup: .inferior, style: .others),
        // Cardio / Full body
        .init(nameKey: "exercise.ot.dancing",              muscleGroup: .fullBody, style: .others),
        .init(nameKey: "exercise.ot.swimming_full",        muscleGroup: .fullBody, style: .others),
        .init(nameKey: "exercise.ot.hiit",                 muscleGroup: .fullBody, style: .others),
        .init(nameKey: "exercise.ot.walking",              muscleGroup: .fullBody, style: .others),
        .init(nameKey: "exercise.ot.yoga_flow",            muscleGroup: .fullBody, style: .others),
    ]
}
