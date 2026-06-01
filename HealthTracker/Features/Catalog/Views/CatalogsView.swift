import SwiftUI

// MARK: - CatalogsView
// Tab 3 — exercise and food catalog management.

struct CatalogsView: View {

    @State private var vm: CatalogViewModel

    init(container: AppContainer) {
        _vm = State(wrappedValue: CatalogViewModel(
            factory:            container.featureFactory,
            exerciseRepository: container.exerciseRepository,
            foodRepository:     container.foodRepository
        ))
    }

    // MARK: - Body

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            ZStack {
                Color.htBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Tab switcher
                    HStack(spacing: HTSpacing.sm) {
                        tabButton(Strings.Catalog.tabExercises, tab: .exercises, vm: vm)
                        tabButton(Strings.Catalog.tabFoods,     tab: .foods,     vm: vm)
                    }
                    .padding(.horizontal, HTSpacing.md)
                    .padding(.vertical, HTSpacing.sm)

                    // Active tab content
                    switch vm.selectedTab {
                    case .exercises:
                        ExerciseCatalogView(vm: vm)
                    case .foods:
                        FoodCatalogView(vm: vm)
                    }
                }
            }
            .navigationTitle(Strings.Catalog.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { await vm.loadAll() }
        .alert(
            Strings.Today.errorTitle,
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )
        ) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func tabButton(_ label: String, tab: CatalogTab, vm: CatalogViewModel) -> some View {
        let isSelected = vm.selectedTab == tab
        Button { vm.selectedTab = tab } label: {
            Text(label)
                .font(HTTypography.subheadlineBold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, HTSpacing.xs)
                .background(isSelected ? Color.htAccent : Color.htSurfaceVariant)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .clipShape(Capsule())
                .overlay {
                    Capsule().strokeBorder(
                        isSelected ? Color.htAccent : Color.htBorder,
                        lineWidth: HTDimensions.Border.regular
                    )
                }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Preview

#Preview {
    CatalogsView(container: .preview)
}
