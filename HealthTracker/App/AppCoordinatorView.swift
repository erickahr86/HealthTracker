import SwiftUI

// MARK: - AppCoordinatorView
// Root tab bar. Each tab will be replaced with its real screen as development progresses.

struct AppCoordinatorView: View {

    let container: AppContainer

    var body: some View {
        TabView {
            // Tab 1: Today
            Text("Today — coming soon")
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }

            // Tab 2: History
            Text("History — coming soon")
                .tabItem {
                    Label("History", systemImage: "clock")
                }

            // Tab 3: Catalogs
            Text("Catalogs — coming soon")
                .tabItem {
                    Label("Catalogs", systemImage: "list.bullet")
                }
        }
        .tint(Color.htAccent)
    }
}

// MARK: - Preview

#Preview {
    AppCoordinatorView(container: .preview)
}
