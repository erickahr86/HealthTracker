import SwiftUI

// MARK: - SettingsView

struct SettingsView: View {

    @State private var vm: SettingsViewModel

    init(container: AppContainer) {
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

                // 3. About
                aboutSection
            }
            .navigationTitle(Strings.Settings.title)
            .scrollContentBackground(.hidden)
            .background(Color.htBackground.ignoresSafeArea())
        }
        .onAppear { vm.loadData() }
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
