import SwiftUI

// MARK: - MealsSectionView
// Shows meal logs grouped by slot (Breakfast, Lunch, Dinner, Snack).

struct MealsSectionView: View {

    @Bindable var vm: DailyReportViewModel
    let onAddInSlot: (MealSlot) -> Void

    @State private var editingLog: MealLog?

    var body: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(Strings.Today.mealsSection,
                          systemImage: "fork.knife")

            ForEach(MealSlot.allCases) { slot in
                MealSlotSection(
                    slot: slot,
                    logs: vm.mealLogs(for: slot),
                    onAdd:    { onAddInSlot(slot) },
                    onEdit:   { editingLog = $0 },
                    onDelete: { vm.removeMealLog($0) }
                )
                if slot != MealSlot.allCases.last {
                    Divider().background(Color.htBorder)
                }
            }
        }
        .htCard()
        .sheet(item: $editingLog) { log in
            EditMealLogSheet(log: log) { updated in
                vm.updateMealLog(updated)
            }
        }
    }
}

// MARK: - MealSlotSection

private struct MealSlotSection: View {

    let slot:     MealSlot
    let logs:     [MealLog]
    let onAdd:    () -> Void
    let onEdit:   (MealLog) -> Void
    let onDelete: (MealLog) -> Void

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
                    MealLogRow(
                        log:      log,
                        onEdit:   { onEdit(log) },
                        onDelete: { onDelete(log) }
                    )
                }
            }
        }
    }
}

// MARK: - MealLogRow

private struct MealLogRow: View {

    let log:      MealLog
    let onEdit:   () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: HTSpacing.sm) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundStyle(Color.htAccent)

            // Tappable area — opens edit sheet
            Button(action: onEdit) {
                HStack {
                    if let food = log.food {
                        Text(food.name)
                            .font(HTTypography.body)
                            .foregroundStyle(.primary)
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
                            .lineLimit(2)
                        Spacer()
                    }
                }
            }
            .buttonStyle(.plain)

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary.opacity(0.6))
                    .padding(.leading, HTSpacing.xs)
            }
            .buttonStyle(.plain)
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
