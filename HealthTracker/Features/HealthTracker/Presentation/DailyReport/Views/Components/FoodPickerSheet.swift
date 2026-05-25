import SwiftUI

// MARK: - FoodPickerSheet
// Pick a food from catalog or enter free text, then confirm with amount.

struct FoodPickerSheet: View {

    let slot: MealSlot
    let foods: [Food]
    let suggestedAmount: (Food) -> Double
    let onConfirm: (MealLog) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var searchText   = ""
    @State private var selected: Food?
    @State private var amountText   = ""
    @State private var freeText     = ""
    @State private var isFreeText   = false

    var body: some View {
        NavigationStack {
            Group {
                if isFreeText {
                    freeTextEntry
                } else if let food = selected {
                    amountAdjuster(for: food)
                } else {
                    foodList
                }
            }
            .navigationTitle(Strings.Today.mealPickerTitle(slot.displayName))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Strings.Today.cancelLabel) {
                        if selected != nil || isFreeText {
                            selected   = nil
                            isFreeText = false
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .background(Color.htBackground.ignoresSafeArea())
        }
    }

    // MARK: - Food list

    private var foodList: some View {
        List {
            // Free-text option at the top
            Section {
                Button {
                    isFreeText = true
                } label: {
                    Label(Strings.Today.freeTextLabel, systemImage: "text.cursor")
                        .foregroundStyle(Color.htAccent)
                }
            }

            // Catalog foods
            Section(Strings.Today.catalogLabel) {
                ForEach(filteredFoods) { food in
                    Button {
                        let amount = suggestedAmount(food)
                        selected   = food
                        amountText = amount.truncatingRemainder(dividingBy: 1) == 0
                            ? String(Int(amount))
                            : String(format: "%.1f", amount)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(food.name)
                                    .foregroundStyle(.primary)
                                Text("\(food.defaultAmount.formatted()) \(food.unit)")
                                    .font(HTTypography.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText,
                    prompt: Strings.Today.searchFoodPlaceholder)
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    private var filteredFoods: [Food] {
        guard !searchText.isEmpty else { return foods }
        return foods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
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
                TextField(Strings.Today.amountPlaceholder,
                          text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text(Strings.Today.amountLabel)
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HTButton(Strings.Today.confirmLabel, systemImage: "plus") {
                guard let food = selected else { return }
                let log = MealLog(
                    food: food,
                    mealSlot: slot,
                    amount: Double(amountText)
                )
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

            VStack(alignment: .leading) {
                TextField(
                    Strings.Today.freeTextPlaceholder,
                    text: $freeText,
                    prompt: Text(Strings.Today.freeTextPlaceholder)
                )
                .font(HTTypography.body)
                .padding(HTSpacing.sm)
                .background(Color.htSurfaceVariant)
                .clipShape(RoundedRectangle(cornerRadius: HTDimensions.CornerRadius.sm))
            }
            .padding(.horizontal, HTSpacing.md)

            Spacer()

            HTButton(Strings.Today.confirmLabel, systemImage: "plus") {
                guard !freeText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                let log = MealLog(
                    food: nil,
                    mealSlot: slot,
                    freeText: freeText.trimmingCharacters(in: .whitespaces)
                )
                onConfirm(log)
                dismiss()
            }
            .padding(.horizontal, HTSpacing.md)
            .padding(.bottom, HTSpacing.md)
        }
    }
}

// MARK: - Preview

#Preview {
    FoodPickerSheet(
        slot: .desayuno,
        foods: [],
        suggestedAmount: { $0.defaultAmount },
        onConfirm: { _ in }
    )
}
