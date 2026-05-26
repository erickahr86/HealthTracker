import SwiftUI

// MARK: - AppCoordinatorView
// Root tab bar. Each tab will be replaced with its real screen as development progresses.

struct AppCoordinatorView: View {

    let container: AppContainer

    var body: some View {
        TabView {
            // Tab 1: Today
            DailyReportView(container: container)
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }

            // Tab 2: History — placeholder
            Text("History — coming soon")
                .tabItem {
                    Label("History", systemImage: "clock")
                }

            // Tab 3: Catalogs — placeholder
            Text("Catalogs — coming soon")
                .tabItem {
                    Label("Catalogs", systemImage: "list.bullet")
                }

            // Tab 4: Settings
            SettingsView(container: container)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(Color.htAccent)
    }
}

// MARK: - Preview

#Preview {
    AppCoordinatorView(container: .preview)
}
