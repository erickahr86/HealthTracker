import SwiftUI

// MARK: - ExercisePickerSheet
// Two-step sheet: pick exercise → adjust weight → confirm.
//
// Data flo
//   DailyReportViewModel.exercises  ← GetExercisesUseCase ← ExerciseRepository (SwiftData)
//   Exercises are seeded during onboarding or added from Settings → Catalog.

struct ExercisePickerSheet: View {

    let exercises:       [Exercise]
    let suggestedWeight: (Exercise) -> (Double, WeightUnit)
    let onConfirm:       (ExerciseLog) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var searchText  = ""
    @State private var selected:   Exercise?
    @State private var weightText  = ""
    @State private var weightUnit: WeightUnit = .kg

    var body: some View {
        NavigationStack {
            Group {
                if let exercise = selected {
                    weightAdjuster(for: exercise)
                } else {
                    exerciseList
                }
            }
            .navigationTitle(Strings.Today.exercisePickerTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Strings.Today.cancelLabel) {
                        if selected != nil { selected = nil } else { dismiss() }
                    }
                }
            }
            .background(Color.htBackground.ignoresSafeArea())
        }
    }

    // MARK: - Exercise list

    @ViewBuilder
    private var exerciseList: some View {
        if exercises.isEmpty {
            emptyCatalogState
        } else {
            populatedList
                .overlay {
                    if filtered.isEmpty {
                        emptySearchState
                    }
                }
        }
    }

    private var populatedList: some View {
        ScrollView {
            VStack(spacing: HTSpacing.md) {
                ForEach(MuscleGroup.allCases, id: \.self) { group in
                    let groupExercises = filtered.filter { $0.muscleGroup == group }
                    if !groupExercises.isEmpty {
                        VStack(alignment: .leading, spacing: HTSpacing.sm) {
                            SectionHeader(group.displayName, systemImage: group.systemImage)
                            ForEach(Array(groupExercises.enumerated()), id: \.element.id) { idx, exercise in
                                if idx > 0 { Divider().background(Color.htBorder) }
                                exerciseRow(exercise)
                            }
                        }
                        .htCard()
                    }
                }
            }
            .padding(HTSpacing.md)
        }
        .searchable(text: $searchText,
                    prompt: Strings.Today.searchExercisePlaceholder)
        .scrollDismissesKeyboard(.interactively)
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        Button {
            let (weight, unit) = suggestedWeight(exercise)
            selected   = exercise
            weightUnit = unit
            weightText = weight.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(weight))
                : String(format: "%.1f", weight)
        } label: {
            HStack {
                Text(exercise.name)
                    .font(HTTypography.body)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private var filtered: [Exercise] {
        guard !searchText.isEmpty else { return exercises }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Empty states

    /// Shown when the catalog has no exercises at all (user skipped onboarding).
    private var emptyCatalogState: some View {
        ContentUnavailableView {
            Label(Strings.Today.exerciseEmpty, systemImage: "dumbbell")
        } description: {
            Text(Strings.Today.exerciseEmptyHint)
        }
    }

    /// Shown when the search query yields no matches.
    private var emptySearchState: some View {
        ContentUnavailableView.search(text: searchText)
    }

    // MARK: - Weight adjuster

    private func weightAdjuster(for exercise: Exercise) -> some View {
        VStack(spacing: HTSpacing.lg) {
            VStack(spacing: HTSpacing.xs) {
                Text(exercise.name)
                    .font(HTTypography.title2)
                Text(exercise.muscleGroup.displayName)
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

            Spacer()

            HTButton(Strings.Today.confirmLabel, systemImage: "plus") {
                guard let exercise = selected,
                      let weight = Double(weightText) else { return }
                let log = ExerciseLog(exercise: exercise,
                                     weight:   weight,
                                     weightUnit: weightUnit)
                onConfirm(log)
                dismiss()
            }
            .padding(.horizontal, HTSpacing.md)
            .padding(.bottom, HTSpacing.md)
        }
    }
}

// MARK: - Preview

#Preview("With exercises") {
    ExercisePickerSheet(
        exercises: [
            Exercise(name: "Bench Press",   defaultWeight: 60, muscleGroup: .superior),
            Exercise(name: "Barbell Squat", defaultWeight: 80, muscleGroup: .inferior),
            Exercise(name: "Treadmill",     defaultWeight:  0, muscleGroup: .fullBody),
        ],
        suggestedWeight: { ($0.defaultWeight, $0.weightUnit) },
        onConfirm: { _ in }
    )
}

#Preview("Empty catalog") {
    ExercisePickerSheet(
        exercises: [],
        suggestedWeight: { ($0.defaultWeight, $0.weightUnit) },
        onConfirm: { _ in }
    )
}
