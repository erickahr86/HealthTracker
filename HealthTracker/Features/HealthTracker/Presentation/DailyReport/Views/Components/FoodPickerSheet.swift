import SwiftUI

// MARK: - FoodPickerSheet
// Three-state sheet:
//   .list            → free-text shortcut + category tabs + food rows
//   .adjustAmount    → numeric amount entry for a catalog food
//   .freeText        → free-form description entry (AI interprets it)
//
// Foods are seeded automatically on first launch by SeedFoodsUseCase.

struct FoodPickerSheet: View {

    let slot:            MealSlot
    let foods:           [Food]
    let suggestedAmount: (Food) -> Double
    let onConfirm:       (MealLog) -> Void

    @Environment(\.dismiss) private var dismiss

    // MARK: State machine

    private enum PickerState { case list, adjustAmount(Food), freeText }
    @State private var state:           PickerState   = .list
    @State private var activeCategory:  FoodCategory  = .protein
    @State private var searchText                     = ""
    @State private var amountText                     = ""
    @State private var freeText                       = ""

    // MARK: - Body

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle(Strings.Today.mealPickerTitle(slot.displayName))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { cancelButton }
                .background(Color.htBackground.ignoresSafeArea())
        }
    }

    // MARK: - Content routing

    @ViewBuilder
    private var contentView: some View {
        switch state {
        case .list:
            listView
        case .adjustAmount(let food):
            amountAdjuster(for: food)
        case .freeText:
            freeTextEntry
        }
    }

    // MARK: - Cancel toolbar

    private var cancelButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(Strings.Today.cancelLabel) {
                switch state {
                case .list:       dismiss()
                default:          state = .list
                }
            }
        }
    }

    // MARK: - List view

    private var listView: some View {
        VStack(spacing: 0) {

            // Free-text option — always prominent at the top
            freeTextBanner
                .padding(.horizontal, HTSpacing.md)
                .padding(.vertical, HTSpacing.sm)

            Divider().background(Color.htBorder)

            // Category tabs — hidden during search
            if searchText.isEmpty {
                categoryTabBar
                    .padding(.vertical, HTSpacing.xs)

                Divider().background(Color.htBorder)
            }

            // Food rows
            foodRows
        }
        .searchable(text: $searchText, prompt: Strings.Today.searchFoodPlaceholder)
    }

    // MARK: Free-text banner

    private var freeTextBanner: some View {
        Button { state = .freeText } label: {
            HStack(spacing: HTSpacing.sm) {
                Image(systemName: "text.cursor")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.htAccent)
                    .frame(width: 36, height: 36)
                    .background(Color.htAccent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: HTDimensions.CornerRadius.sm))

                VStack(alignment: .leading, spacing: 2) {
                    Text(Strings.Today.freeTextLabel)
                        .font(HTTypography.bodyBold)
                        .foregroundStyle(.primary)
                    Text(Strings.Today.freeTextSubtitle)
                        .font(HTTypography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: Category tab bar

    private var categoryTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: HTSpacing.xs) {
                ForEach(FoodCategory.allCases, id: \.self) { category in
                    categoryTab(for: category)
                }
            }
            .padding(.horizontal, HTSpacing.md)
        }
    }

    private func categoryTab(for category: FoodCategory) -> some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                activeCategory = category
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: category.systemImage)
                    .font(.system(size: 12, weight: .medium))
                Text(category.displayName)
                    .font(HTTypography.subheadlineBold)
            }
            .padding(.horizontal, HTSpacing.sm)
            .padding(.vertical, HTSpacing.xs)
            .background(activeCategory == category ? Color.htAccent : Color.htSurfaceVariant)
            .foregroundStyle(activeCategory == category ? Color.white : Color.primary)
            .clipShape(Capsule())
            .overlay {
                Capsule().strokeBorder(
                    activeCategory == category ? Color.htAccent : Color.htBorder,
                    lineWidth: HTDimensions.Border.regular
                )
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25), value: activeCategory)
    }

    // MARK: Food rows

    @ViewBuilder
    private var foodRows: some View {
        let rows = searchText.isEmpty ? foodsIn(activeCategory) : filteredFoods
        if rows.isEmpty {
            if searchText.isEmpty {
                // Category is empty (e.g., all custom foods have no category)
                ContentUnavailableView(
                    Strings.Today.mealSlotEmpty,
                    systemImage: "fork.knife"
                )
            } else {
                ContentUnavailableView.search(text: searchText)
            }
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { idx, food in
                        if idx > 0 { Divider().background(Color.htBorder) }
                        foodRow(food)
                    }
                }
                .htCard()
                .padding(HTSpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private func foodRow(_ food: Food) -> some View {
        Button {
            let amount = suggestedAmount(food)
            amountText = amount.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(amount))
                : String(format: "%.1f", amount)
            state = .adjustAmount(food)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(food.name)
                        .font(HTTypography.body)
                        .foregroundStyle(.primary)
                    Text("\(food.defaultAmount.formatted()) \(food.unit)")
                        .font(HTTypography.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, HTSpacing.sm)
        }
        .buttonStyle(.plain)
    }

    // MARK: Filtering

    private func foodsIn(_ category: FoodCategory) -> [Food] {
        foods.filter { $0.category == category }
    }

    private var filteredFoods: [Food] {
        foods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Amount adjuster

    private func amountAdjuster(for food: Food) -> some View {
        VStack(spacing: HTSpacing.lg) {
            VStack(spacing: HTSpacing.xs) {
                Text(food.name)
                    .font(HTTypography.title2)
                Text(food.unit)
                    .font(HTTypography.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, HTSpacing.lg)

            VStack(spacing: HTSpacing.xs) {
                TextField(Strings.Today.amountPlaceholder, text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text(Strings.Today.amountLabel)
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HTButton(Strings.Today.confirmLabel, systemImage: "plus") {
                guard case .adjustAmount(let food) = state else { return }
                let log = MealLog(food: food, mealSlot: slot, amount: Double(amountText))
                onConfirm(log)
                dismiss()
            }
            .padding(.horizontal, HTSpacing.md)
            .padding(.bottom, HTSpacing.md)
        }
    }

    // MARK: - Free text entry

    private var freeTextEntry: some View {
        VStack(spacing: HTSpacing.lg) {
            VStack(spacing: HTSpacing.xs) {
                Text(slot.displayName)
                    .font(HTTypography.title2)
                Text(Strings.Today.freeTextSubtitle)
                    .font(HTTypography.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, HTSpacing.lg)

            TextField(
                Strings.Today.freeTextPlaceholder,
                text: $freeText,
                axis: .vertical
            )
            .font(HTTypography.body)
            .lineLimit(3...6)
            .padding(HTSpacing.sm)
            .background(Color.htSurfaceVariant)
            .clipShape(RoundedRectangle(cornerRadius: HTDimensions.CornerRadius.sm))
            .padding(.horizontal, HTSpacing.md)

            Spacer()

            HTButton(Strings.Today.confirmLabel, systemImage: "plus") {
                let trimmed = freeText.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                let log = MealLog(food: nil, mealSlot: slot, freeText: trimmed)
                onConfirm(log)
                dismiss()
            }
            .padding(.horizontal, HTSpacing.md)
            .padding(.bottom, HTSpacing.md)
        }
    }
}

// MARK: - Previews

#Preview("With foods") {
    FoodPickerSheet(
        slot: .desayuno,
        foods: [
            Food(name: "Chicken Breast", unit: "g",   defaultAmount: 150, category: .protein),
            Food(name: "White Rice",     unit: "g",   defaultAmount: 100, category: .grains),
            Food(name: "Broccoli",       unit: "g",   defaultAmount: 100, category: .vegetables),
        ],
        suggestedAmount: { $0.defaultAmount },
        onConfirm: { _ in }
    )
}

#Preview("Empty catalog") {
    FoodPickerSheet(
        slot: .comida,
        foods: [],
        suggestedAmount: { $0.defaultAmount },
        onConfirm: { _ in }
    )
}
