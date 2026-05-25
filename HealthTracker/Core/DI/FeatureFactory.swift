import Foundation

// MARK: - FeatureFactory
// Creates use case instances for the HealthTracker feature.
// Each factory method returns a fresh instance — use cases are stateless orchestrators.

final class FeatureFactory {

    // MARK: - Dependencies

    private let dailyReportRepository: any DailyReportRepository
    private let exerciseRepository:    any ExerciseRepository
    private let foodRepository:        any FoodRepository
    private let aiProviderRepository:  any AIProviderRepository
    private let providerFactory:       ProviderFactory

    // MARK: - Init

    init(
        dailyReportRepository: any DailyReportRepository,
        exerciseRepository:    any ExerciseRepository,
        foodRepository:        any FoodRepository,
        aiProviderRepository:  any AIProviderRepository,
        providerFactory:       ProviderFactory
    ) {
        self.dailyReportRepository = dailyReportRepository
        self.exerciseRepository    = exerciseRepository
        self.foodRepository        = foodRepository
        self.aiProviderRepository  = aiProviderRepository
        self.providerFactory       = providerFactory
    }

    // MARK: - Use Cases

    func makeGetOrCreateTodayReportUseCase() -> any GetOrCreateTodayReportUseCase {
        GetOrCreateTodayReportUseCaseImpl(reportRepository: dailyReportRepository)
    }

    func makeSaveDailyReportUseCase() -> any SaveDailyReportUseCase {
        SaveDailyReportUseCaseImpl(reportRepository: dailyReportRepository)
    }

    func makeGetReportHistoryUseCase() -> any GetReportHistoryUseCase {
        GetReportHistoryUseCaseImpl(reportRepository: dailyReportRepository)
    }

    func makeGetExercisesUseCase() -> any GetExercisesUseCase {
        GetExercisesUseCaseImpl(exerciseRepository: exerciseRepository)
    }

    func makeGetFoodsUseCase() -> any GetFoodsUseCase {
        GetFoodsUseCaseImpl(foodRepository: foodRepository)
    }

    func makeAddCustomExerciseUseCase() -> any AddCustomExerciseUseCase {
        AddCustomExerciseUseCaseImpl(exerciseRepository: exerciseRepository)
    }

    func makeAddCustomFoodUseCase() -> any AddCustomFoodUseCase {
        AddCustomFoodUseCaseImpl(foodRepository: foodRepository)
    }

    func makeAnalyzeReportWithAIUseCase() -> any AnalyzeReportWithAIUseCase {
        AnalyzeReportWithAIUseCaseImpl(
            llmProvider:          providerFactory.makeLLMProvider(),
            aiProviderRepository: aiProviderRepository,
            reportRepository:     dailyReportRepository
        )
    }
}
