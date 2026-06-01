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
            ScrollView {
                VStack(spacing: HTSpacing.md) {

                    // 1. Health profile
                    profileCard

                    // 2. AI Provider + API key
                    APIKeySectionView(vm: vm)

                    // 3. Unit preferences
                    MeasurementsSectionView(vm: vm)

                    // 4. Catalog
                    catalogCard

                    // 5. About
                    aboutCard
                }
                .padding(HTSpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.htBackground.ignoresSafeArea())
            .navigationTitle(Strings.Settings.title)
            .navigationBarTitleDisplayMode(.large)
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

    // MARK: - Profile card

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: HTSpacing.xs) {
            VStack(alignment: .leading, spacing: HTSpacing.sm) {
                SectionHeader(Strings.Settings.profileSection, systemImage: "person.crop.circle")

                NavigationLink {
                    UserProfileView(repository: container.featureFactory.userPreferencesRepository)
                } label: {
                    HStack {
                        Label(Strings.Settings.profileLabel, systemImage: "person")
                            .font(HTTypography.body)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .htCard()

            Text(Strings.Settings.profileHint)
                .font(HTTypography.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, HTSpacing.xs)
        }
    }

    // MARK: - Catalog card

    private var catalogCard: some View {
        VStack(alignment: .leading, spacing: HTSpacing.xs) {
            VStack(alignment: .leading, spacing: HTSpacing.sm) {
                SectionHeader(Strings.Settings.catalogSection, systemImage: "list.bullet")

                Button { showExerciseCatalog = true } label: {
                    HStack {
                        Label(Strings.Settings.exerciseCatalog, systemImage: "dumbbell")
                            .font(HTTypography.body)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
            .htCard()

            Text(Strings.Settings.exerciseCatalogHint)
                .font(HTTypography.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, HTSpacing.xs)
        }
    }

    // MARK: - About card

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(Strings.Settings.aboutSection, systemImage: "info.circle")

            HStack {
                Text(Strings.Settings.versionLabel)
                    .font(HTTypography.body)
                Spacer()
                Text(vm.appVersion)
                    .font(HTTypography.body)
                    .foregroundStyle(.secondary)
            }

            Divider().background(Color.htBorder)

            Link(destination: URL(string: "https://console.anthropic.com/docs")!) {
                HStack {
                    Label(Strings.Settings.anthropicDocs, systemImage: "book")
                        .font(HTTypography.body)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(Color.htAccent)
                }
            }
        }
        .htCard()
    }
}

// MARK: - Preview

#Preview {
    SettingsView(container: .preview)
}
