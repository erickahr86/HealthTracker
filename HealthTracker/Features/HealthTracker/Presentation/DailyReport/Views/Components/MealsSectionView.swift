import SwiftUI

// MARK: - MealsSectionView
// Shows meal logs grouped by slot (Breakfast, Lunch, Dinner, Snack).

struct MealsSectionView: View {

    @Bindable var vm: DailyReportViewModel
    let onAddInSlot: (MealSlot) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(Strings.Today.mealsSection,
                          systemImage: "fork.knife")

            ForEach(MealSlot.allCases) { slot in
                MealSlotSection(
                    slot: slot,
                    logs: vm.mealLogs(for: slot),
                    onAdd: { onAddInSlot(slot) },
                    onDelete: { vm.removeMealLogs(in: slot, at: $0) }
                )
                if slot != MealSlot.allCases.last {
                    Divider().background(Color.htBorder)
                }
            }
        }
        .htCard()
    }
}

// MARK: - MealSlotSection

private struct MealSlotSection: View {

    let slot: MealSlot
    let logs: [MealLog]
    let onAdd: () -> Void
    let onDelete: (IndexSet) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: HTSpacing.xs) {
            // Slot header row
            HStack {
                Text(slot.displayName)
                    .font(HTTypography.subheadlineBold)
                    .foregroundStyle(.primary)
                Spacer()
                Button(action: onAdd) {
                    Label(Strings.Today.addLabel, systemImage: "plus")
                        .font(HTTypography.caption)
                        .foregroundStyle(Color.htAccent)
                }
            }

            if logs.isEmpty {
                Text(Strings.Today.mealSlotEmpty)
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, HTSpacing.xs)
            } else {
                ForEach(logs) { log in
                    MealLogRow(log: log)
                }
                .onDelete(perform: onDelete)
            }
        }
    }
}

// MARK: - MealLogRow

private struct MealLogRow: View {

    let log: MealLog

    var body: some View {
        HStack(spacing: HTSpacing.sm) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundStyle(Color.htAccent)

            if let food = log.food {
                Text(food.name)
                    .font(HTTypography.body)
                Spacer()
                if let amount = log.amount {
                    let formatted = amount.truncatingRemainder(dividingBy: 1) == 0
                        ? String(Int(amount))
                        : String(format: "%.1f", amount)
                    Text("\(formatted) \(food.unit)")
                        .font(HTTypography.caption)
                        .foregroundStyle(.secondary)
                }
            } else if let text = log.freeText {
                Text(text)
                    .font(HTTypography.body)
                    .foregroundStyle(.primary)
                Spacer()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var vm = DailyReportViewModel(factory: AppContainer.preview.featureFactory)
    MealsSectionView(vm: vm, onAddInSlot: { _ in })
        .padding(HTSpacing.md)
        .background(Color.htBackground)
}
