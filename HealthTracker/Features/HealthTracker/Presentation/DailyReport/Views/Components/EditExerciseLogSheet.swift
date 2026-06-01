import SwiftUI

// MARK: - EditExerciseLogSheet
// Pre-populated weight adjuster for an existing ExerciseLog.
// Same visual design as the weight step in ExercisePickerSheet.

struct EditExerciseLogSheet: View {

    let log:       ExerciseLog
    let onConfirm: (ExerciseLog) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var weightText: String
    @State private var weightUnit: WeightUnit

    init(log: ExerciseLog, onConfirm: @escaping (ExerciseLog) -> Void) {
        self.log       = log
        self.onConfirm = onConfirm
        let w = log.weight
        _weightText = State(initialValue: w.truncatingRemainder(dividingBy: 1) == 0
                                ? String(Int(w))
                                : String(format: "%.1f", w))
        _weightUnit = State(initialValue: log.weightUnit)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: HTSpacing.lg) {

                // Exercise info
                VStack(spacing: HTSpacing.xs) {
                    Text(log.exercise.name)
                        .font(HTTypography.title2)
                    Text(log.exercise.muscleGroup.displayName)
                        .font(HTTypography.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, HTSpacing.lg)

                // Weight field + unit picker
                VStack(spacing: HTSpacing.sm) {
                    HStack(spacing: HTSpacing.sm) {
                        TextField(Strings.Today.weightPlaceholder, text: $weightText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 160)

                        Picker("", selection: $weightUnit) {
                            ForEach(WeightUnit.allCases, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)
                    }
                    Text(Strings.Today.weightLabel)
                        .font(HTTypography.caption)
                        .foregroundStyle(.secondary)
                }
                .htCard()
                .padding(.horizontal, HTSpacing.md)

                Spacer()

                HTButton(Strings.Today.confirmLabel, systemImage: "checkmark") {
                    guard let weight = Double(weightText) else { return }
                    var updated       = log
                    updated.weight    = weight
                    updated.weightUnit = weightUnit
                    onConfirm(updated)
                    dismiss()
                }
                .padding(.horizontal, HTSpacing.md)
                .padding(.bottom, HTSpacing.md)
            }
            .navigationTitle(Strings.Today.editExerciseTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Strings.Today.cancelLabel) { dismiss() }
                }
            }
            .background(Color.htBackground.ignoresSafeArea())
        }
    }
}

// MARK: - Preview

#Preview {
    EditExerciseLogSheet(
        log: ExerciseLog(
            exercise: Exercise(name: "Bench Press", defaultWeight: 60, muscleGroup: .superior),
            weight: 62.5,
            weightUnit: .kg
        ),
        onConfirm: { _ in }
    )
    .preferredColorScheme(.dark)
}
