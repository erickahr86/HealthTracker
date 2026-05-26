import Foundation
import SwiftData

// MARK: - AppContainer
// Root dependency injection container.
// Owns all shared instances and wires the dependency graph at app startup.
// Use AppContainer.shared in production, AppContainer.preview in SwiftUI Previews.

@MainActor
final class AppContainer {

    // MARK: - Shared instances

    static let shared: AppContainer = AppContainer(inMemory: false)

    /// In-memory container for SwiftUI Previews and unit tests.
    static let preview: AppContainer = AppContainer(inMemory: true)

    // MARK: - Public: Repositories

    let dailyReportRepository:    any DailyReportRepository
    let exerciseRepository:       any ExerciseRepository
    let foodRepository:           any FoodRepository
    let aiProviderRepository:     any AIProviderRepository
    let userPreferencesRepository: any UserPreferencesRepository

    // MARK: - Public: ModelContainer (for .modelContainer() scene modifier)

    let modelContainer: ModelContainer

    // MARK: - Public: Factories

    let providerFactory: ProviderFactory
    let featureFactory:  FeatureFactory

    // MARK: - Init

    private init(inMemory: Bool) {
        let persistence = inMemory ? PersistenceController.preview : PersistenceController.shared
        modelContainer = persistence.container
        let context = persistence.mainContext

        // Build repositories
        let dailyRepo    = DailyReportRepositoryImpl(context: context)
        let exerciseRepo = ExerciseRepositoryImpl(context: context)
        let foodRepo     = FoodRepositoryImpl(context: context)
        let aiRepo       = AIProviderRepositoryImpl()
        let prefsRepo    = UserPreferencesRepositoryImpl()

        dailyReportRepository     = dailyRepo
        exerciseRepository        = exerciseRepo
        foodRepository            = foodRepo
        aiProviderRepository      = aiRepo
        userPreferencesRepository = prefsRepo

        // Build factories
        let pFactory = ProviderFactory(aiProviderRepository: aiRepo)
        providerFactory = pFactory
        featureFactory  = FeatureFactory(
            dailyReportRepository:    dailyRepo,
            exerciseRepository:       exerciseRepo,
            foodRepository:           foodRepo,
            aiProviderRepository:     aiRepo,
            userPreferencesRepository: prefsRepo,
            providerFactory:          pFactory
        )
    }
}
