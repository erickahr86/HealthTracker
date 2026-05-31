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
        .task {
            try? await container.featureFactory.makeSeedFoodsUseCase().execute()
            try? await container.featureFactory.makeDeduplicateCatalogsUseCase().execute()
        }
    }

    // MARK: - Main tab view

    private var mainTabView: some View {
        TabView {
            // Tab 1: Today
            DailyReportView(container: container)
                .tabItem {
                    Label(Strings.Tab.today, systemImage: "calendar")
                }

            // Tab 2: History
            ReportHistoryView(container: container)
                .tabItem {
                    Label(Strings.Tab.history, systemImage: "clock")
                }

            // Tab 3: Catalog
            CatalogsView(container: container)
                .tabItem {
                    Label(Strings.Tab.catalog, systemImage: "square.grid.2x2")
                }

            // Tab 4: Settings
            SettingsView(container: container)
                .tabItem {
                    Label(Strings.Tab.settings, systemImage: "gearshape")
                }
        }
        .tint(Color.htAccent)
    }
}

// MARK: - Preview

#Preview {
    AppCoordinatorView(container: .preview)
}
