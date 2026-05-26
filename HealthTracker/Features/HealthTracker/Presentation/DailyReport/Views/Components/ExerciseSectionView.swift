import SwiftUI

// MARK: - ExerciseSectionView

struct ExerciseSectionView: View {

    @Bindable var vm: DailyReportViewModel
    let onAdd: () -> Void

    @State private var editingLog: ExerciseLog?

    var body: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(
                Strings.Today.exerciseSection,
                systemImage: "dumbbell.fill",
                actionLabel: Strings.Today.addLabel,
                action: onAdd
            )

            if vm.report.exerciseLogs.isEmpty {
                emptyState
            } else {
                ForEach(vm.report.exerciseLogs) { log in
                    ExerciseLogRow(
                        log: log,
                        onEdit:   { editingLog = log },
                        onDelete: { vm.removeExerciseLog(log) }
                    )
                    if log.id != vm.report.exerciseLogs.last?.id {
                        Divider().background(Color.htBorder)
                    }
                }
            }
        }
        .htCard()
        .sheet(item: $editingLog) { log in
            EditExerciseLogSheet(log: log) { updated in
                vm.updateExerciseLog(updated)
            }
        }
    }

    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: HTSpacing.xs) {
                Image(systemName: "dumbbell")
                    .font(.system(size: HTDimensions.Icon.lg))
                    .foregroundStyle(.secondary.opacity(0.5))
                Text(Strings.Today.exerciseEmpty)
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, HTSpacing.md)
            Spacer()
        }
    }
}

// MARK: - ExerciseLogRow

private struct ExerciseLogRow: View {

    let log:      ExerciseLog
    let onEdit:   () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: HTSpacing.sm) {
            // Tappable area — opens edit sheet
            Button(action: onEdit) {
                HStack(spacing: HTSpacing.sm) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(log.exercise.name)
                            .font(HTTypography.body)
                            .foregroundStyle(.primary)
                        Text(log.exercise.muscleGroup.displayName)
                            .font(HTTypography.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(weightLabel)
                        .font(HTTypography.bodyBold)
                        .foregroundStyle(Color.htAccent)
                }
            }
            .buttonStyle(.plain)

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondary.opacity(0.6))
                    .padding(.leading, HTSpacing.xs)
            }
            .buttonStyle(.plain)
        }
    }

    private var weightLabel: String {
        let value = log.weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(log.weight))
            : String(format: "%.1f", log.weight)
        return "\(value) \(log.weightUnit.displayName)"
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var vm = DailyReportViewModel(factory: AppContainer.preview.featureFactory)
    ExerciseSectionView(vm: vm, onAdd: {})
        .padding(HTSpacing.md)
        .background(Color.htBackground)
}
