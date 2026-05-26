import SwiftUI

// MARK: - AppCoordinatorView
// Root coordinator. Shows OnboardingView on first launch;
// switches to the main TabView once onboarding is complete.

struct AppCoordinatorView: View {

    let container: AppContainer

    @State private var showOnboarding = false

    var body: some View {
        Group {
            if showOnboarding {
                OnboardingView(container: container) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showOnboarding = false
                    }
                }
            } else {
                mainTabView
            }
        }
        .onAppear {
            showOnboarding = !container.userPreferencesRepository.hasCompletedOnboarding()
        }
    }

    // MARK: - Main tab view

    private var mainTabView: some View {
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
