import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

    let container: AppContainer

    @State private var vm:                  SettingsViewModel
    @State private var showExerciseCatalog = false

    init(container: AppContainer) {
        self.container = container
        _vm = State(wrappedValue: SettingsViewModel(container: container))
    }

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            Form {
                // 1. AI Provider + API key
                APIKeySectionView(vm: vm)

                // 2. Unit preferences
                MeasurementsSectionView(vm: vm)

                // 3. Catalog
                catalogSection

                // 4. About
                aboutSection
            }
            .navigationTitle(Strings.Settings.title)
            .scrollContentBackground(.hidden)
            .background(Color.htBackground.ignoresSafeArea())
        }
        .onAppear { vm.loadData() }
        .fullScreenCover(isPresented: $showExerciseCatalog) {
            OnboardingView(
                container:    container,
                startingStep: .exerciseSelection,
                onComplete:   { showExerciseCatalog = false }
            )
        }
    }

    // MARK: - Catalog section

    private var catalogSection: some View {
        Section {
            Button {
                showExerciseCatalog = true
            } label: {
                Label(Strings.Settings.exerciseCatalog, systemImage: "dumbbell")
                    .foregroundStyle(Color.primary)
            }
        } header: {
            Text(Strings.Settings.catalogSection)
        } footer: {
            Text(Strings.Settings.exerciseCatalogHint)
        }
    }

    // MARK: - About section

    private var aboutSection: some View {
        Section(Strings.Settings.aboutSection) {
            LabeledContent(Strings.Settings.versionLabel, value: vm.appVersion)

            Link(destination: URL(string: "https://console.anthropic.com/docs")!) {
                Label(Strings.Settings.anthropicDocs, systemImage: "book")
            }
            .tint(Color.htAccent)
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView(container: .preview)
}
