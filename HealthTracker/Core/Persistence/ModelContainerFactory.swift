import Foundation
import SwiftData

// MARK: - ModelContainerFactory

enum ModelContainerFactory {

    /// All SwiftData models registered in the schema.
    static let schema = Schema([
        DailyReportModel.self,
        ExerciseModel.self,
        FoodModel.self,
        ExerciseLogModel.self,
        MealLogModel.self
    ])

    /// Local persistent container. Use this in production.
    static func makeContainer() -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    /// In-memory container for SwiftUI Previews and unit tests.
    static func makeInMemoryContainer() -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Failed to create in-memory ModelContainer: \(error)")
        }
    }
}
