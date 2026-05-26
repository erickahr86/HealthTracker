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
                    Picker(Strings.Catalog.title, selection: $vm.selectedTab) {
                        Text(Strings.Catalog.tabExercises).tag(CatalogTab.exercises)
                        Text(Strings.Catalog.tabFoods).tag(CatalogTab.foods)
                    }
                    .pickerStyle(.segmented)
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
}

// MARK: - Preview

#Preview {
    CatalogsView(container: .preview)
}
