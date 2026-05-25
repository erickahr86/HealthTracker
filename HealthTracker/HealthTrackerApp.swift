import SwiftUI
import SwiftData

@main
struct HealthTrackerApp: App {

    @State private var container = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(container: container)
        }
        .modelContainer(container.modelContainer)
    }
}
