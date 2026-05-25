import Foundation
import SwiftData

// MARK: - PersistenceController

/// Manages access to the shared ModelContainer and provides ModelContexts.
/// Use `shared` in production and `preview` in SwiftUI previews / tests.
@MainActor
final class PersistenceController {

    // MARK: Shared Instances

    static let shared  = PersistenceController()
    static let preview = PersistenceController(inMemory: true)

    // MARK: Properties

    let container: ModelContainer

    var mainContext: ModelContext {
        container.mainContext
    }

    // MARK: Init

    private init(inMemory: Bool = false) {
        container = inMemory
            ? ModelContainerFactory.makeInMemoryContainer()
            : ModelContainerFactory.makeContainer()
    }

    // MARK: Background Context

    /// Creates a new context for background operations.
    func newBackgroundContext() -> ModelContext {
        ModelContext(container)
    }
}
