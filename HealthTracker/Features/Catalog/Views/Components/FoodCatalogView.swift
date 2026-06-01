import SwiftUI

// MARK: - FoodCatalogView
// Grouped list of all foods with add/delete custom food support.

struct FoodCatalogView: View {

    @Bindable var vm: CatalogViewModel

    @State private var showAddSheet  = false
    @State private var foodToDelete: Food? = nil

    var body: some View {
        ZStack {
            Color.htBackground.ignoresSafeArea()

            if vm.foods.isEmpty {
                emptyView
            } else {
                foodList
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddFoodSheet { name, unit, amount, category in
                await vm.addFood(name: name, unit: unit, defaultAmount: amount, category: category)
            }
        }
        .confirmationDialog(
            Strings.Catalog.deleteTitle,
            isPresented: Binding(
                get: { foodToDelete != nil },
                set: { if !$0 { foodToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(Strings.Catalog.deleteConfirm, role: .destructive) {
                if let f = foodToDelete {
                    Task { await vm.deleteFood(f) }
                }
                foodToDelete = nil
            }
            Button(Strings.Catalog.cancel, role: .cancel) {
                foodToDelete = nil
            }
        } message: {
            Text(Strings.Catalog.deleteMessage)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
                .tint(Color.htAccent)
            }
        }
    }

    // MARK: - Empty state

    private var emptyView: some View {
        VStack(spacing: HTSpacing.md) {
            Image(systemName: "fork.knife")
                .font(.system(size: HTDimensions.Icon.xl))
                .foregroundStyle(.secondary)
            Text(Strings.Catalog.emptyFoods)
                .font(HTTypography.body)
                .foregroundStyle(.secondary)
            Button(Strings.Catalog.addFood) {
                showAddSheet = true
            }
            .tint(Color.htAccent)
        }
    }

    // MARK: - List

    private var foodList: some View {
        ScrollView {
            VStack(spacing: HTSpacing.md) {
                ForEach(vm.foodsByCategory, id: \.0) { category, foods in
                    let cat = category ?? FoodCategory.other
                    VStack(alignment: .leading, spacing: HTSpacing.sm) {
                        SectionHeader(cat.displayName, systemImage: cat.systemImage)
                        ForEach(Array(foods.enumerated()), id: \.element.id) { idx, food in
                            if idx > 0 { Divider().background(Color.htBorder) }
                            foodRow(food)
                        }
                    }
                    .htCard()
                }
            }
            .padding(HTSpacing.md)
        }
    }

    @ViewBuilder
    private func foodRow(_ food: Food) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: HTSpacing.xxs) {
                Text(food.name)
                    .font(HTTypography.bodyMedium)
                    .foregroundStyle(.primary)

                Text(Strings.Catalog.foodDefaultAmount(food.defaultAmount, food.unit))
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                foodToDelete = food
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: HTDimensions.Icon.sm))
                    .foregroundStyle(Color.htTrafficRed)
            }
            .buttonStyle(.plain)
        }
    }

}

// MARK: - Preview

#Preview {
    NavigationStack {
        FoodCatalogView(vm: CatalogViewModel(
            factory:            AppContainer.preview.featureFactory,
            exerciseRepository: AppContainer.preview.exerciseRepository,
            foodRepository:     AppContainer.preview.foodRepository
        ))
    }
    .preferredColorScheme(.dark)
}
