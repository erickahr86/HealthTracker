import SwiftUI

// MARK: - AddExerciseSheet
// Modal form for creating a new custom exercise.

struct AddExerciseSheet: View {

    @Environment(\.dismiss) private var dismiss

    let onSave: (String, Double, WeightUnit, MuscleGroup) async -> Void

    @State private var name        = ""
    @State private var weightText  = ""
    @State private var weightUnit  = WeightUnit.kg
    @State private var muscleGroup = MuscleGroup.superior
    @State private var isSaving    = false

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // Name
                Section {
                    TextField(Strings.Catalog.exerciseNamePlaceholder, text: $name)
                        .autocorrectionDisabled()
                } header: {
                    Text(Strings.Catalog.nameLabel)
                }

                // Muscle group
                Section {
                    Picker(Strings.Catalog.muscleGroupLabel, selection: $muscleGroup) {
                        ForEach(MuscleGroup.allCases, id: \.self) { group in
                            Text(group.displayName).tag(group)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text(Strings.Catalog.muscleGroupLabel)
                }

                // Default weight
                Section {
                    HStack(spacing: HTSpacing.xs) {
                        TextField("0", text: $weightText)
                            .keyboardType(.decimalPad)

                        Picker("", selection: $weightUnit) {
                            ForEach(WeightUnit.allCases, id: \.self) { unit in
                                Text(unit.displayName).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                        .fixedSize()
                    }
                } header: {
                    Text(Strings.Catalog.weightLabel)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .background(Color.htBackground.ignoresSafeArea())
            .navigationTitle(Strings.Catalog.addExercise)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Strings.Catalog.cancel) { dismiss() }
                        .tint(Color.htAccent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Strings.Catalog.save) {
                        let w = Double(
                            weightText.replacingOccurrences(of: ",", with: ".")
                        ) ?? 0
                        isSaving = true
                        Task {
                            await onSave(
                                name.trimmingCharacters(in: .whitespaces),
                                w,
                                weightUnit,
                                muscleGroup
                            )
                            dismiss()
                        }
                    }
                    .disabled(!isValid || isSaving)
                    .fontWeight(.semibold)
                    .tint(Color.htAccent)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddExerciseSheet { _, _, _, _ in }
}
