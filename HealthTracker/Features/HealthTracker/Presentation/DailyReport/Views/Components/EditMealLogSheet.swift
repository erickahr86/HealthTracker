import SwiftUI

// MARK: - EditMealLogSheet
// Pre-populated editor for an existing MealLog.
// - Catalog food  → shows amount TextField
// - Free text     → shows multiline text editor
// Same visual design as the corresponding steps in FoodPickerSheet.

struct EditMealLogSheet: View {

    let log:       MealLog
    let onConfirm: (MealLog) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var amountText: String
    @State private var freeText:   String

    init(log: MealLog, onConfirm: @escaping (MealLog) -> Void) {
        self.log       = log
        self.onConfirm = onConfirm

        if let amount = log.amount {
            _amountText = State(initialValue: amount.truncatingRemainder(dividingBy: 1) == 0
                                    ? String(Int(amount))
                                    : String(format: "%.1f", amount))
        } else {
            _amountText = State(initialValue: "")
        }
        _freeText = State(initialValue: log.freeText ?? "")
    }

    var body: some View {
        NavigationStack {
            Group {
                if log.food != nil {
                    amountView
                } else {
                    freeTextView
                }
            }
            .navigationTitle(Strings.Today.editMealTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Strings.Today.cancelLabel) { dismiss() }
                }
            }
            .background(Color.htBackground.ignoresSafeArea())
        }
    }

    // MARK: - Catalog food — amount editor

    private var amountView: some View {
        VStack(spacing: HTSpacing.lg) {
            if let food = log.food {
                VStack(spacing: HTSpacing.xs) {
                    Text(food.name)
                        .font(HTTypography.title2)
                    Text(food.unit)
                        .font(HTTypography.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, HTSpacing.lg)
            }

            VStack(spacing: HTSpacing.xs) {
                TextField(Strings.Today.amountPlaceholder, text: $amountText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text(Strings.Today.amountLabel)
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
            }
            .htCard()
            .padding(.horizontal, HTSpacing.md)

            Spacer()

            HTButton(Strings.Today.confirmLabel, systemImage: "checkmark") {
                var updated    = log
                updated.amount = Double(amountText)
                onConfirm(updated)
                dismiss()
            }
            .padding(.horizontal, HTSpacing.md)
            .padding(.bottom, HTSpacing.md)
        }
    }

    // MARK: - Free text editor

    private var freeTextView: some View {
        VStack(spacing: HTSpacing.lg) {
            VStack(spacing: HTSpacing.xs) {
                Text(log.mealSlot.displayName)
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
            .htCard()
            .padding(.horizontal, HTSpacing.md)

            Spacer()

            HTButton(Strings.Today.confirmLabel, systemImage: "checkmark") {
                let trimmed = freeText.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                var updated      = log
                updated.freeText = trimmed
                onConfirm(updated)
                dismiss()
            }
            .padding(.horizontal, HTSpacing.md)
            .padding(.bottom, HTSpacing.md)
        }
    }
}

// MARK: - Preview

#Preview("Catalog food") {
    EditMealLogSheet(
        log: MealLog(
            food: Food(name: "Chicken Breast", unit: "g", defaultAmount: 150, category: .protein),
            mealSlot: .comida,
            amount: 120
        ),
        onConfirm: { _ in }
    )
    .preferredColorScheme(.dark)
}

#Preview("Free text") {
    EditMealLogSheet(
        log: MealLog(food: nil, mealSlot: .desayuno, freeText: "Scrambled eggs with toast"),
        onConfirm: { _ in }
    )
    .preferredColorScheme(.dark)
}
