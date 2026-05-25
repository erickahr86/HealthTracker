import SwiftUI

// MARK: - ExerciseSectionView

struct ExerciseSectionView: View {

    @Bindable var vm: DailyReportViewModel
    let onAdd: () -> Void

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
                    ExerciseLogRow(log: log)
                    if log.id != vm.report.exerciseLogs.last?.id {
                        Divider().background(Color.htBorder)
                    }
                }
                .onDelete { vm.removeExerciseLogs(at: $0) }
            }
        }
        .htCard()
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

    let log: ExerciseLog

    var body: some View {
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

    private var weightLabel: String {
        let formatted = log.weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(log.weight))
            : String(format: "%.1f", log.weight)
        return "\(formatted) \(log.weightUnit.displayName)"
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var vm = DailyReportViewModel(factory: AppContainer.preview.featureFactory)
    ExerciseSectionView(vm: vm, onAdd: {})
        .padding(HTSpacing.md)
        .background(Color.htBackground)
}
