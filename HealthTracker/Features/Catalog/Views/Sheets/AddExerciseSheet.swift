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
            ScrollView {
                VStack(spacing: HTSpacing.md) {
                    VStack(alignment: .leading, spacing: HTSpacing.sm) {
                        HStack {
                            Text(Strings.Catalog.nameLabel)
                                .font(HTTypography.body)
                            Spacer()
                            TextField(Strings.Catalog.exerciseNamePlaceholder, text: $name)
                                .autocorrectionDisabled()
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.vertical, HTSpacing.xs)

                        Divider().background(Color.htBorder)

                        HStack {
                            Text(Strings.Catalog.muscleGroupLabel)
                                .font(HTTypography.body)
                            Spacer()
                            Picker("", selection: $muscleGroup) {
                                ForEach(MuscleGroup.allCases, id: \.self) { group in
                                    Text(group.displayName).tag(group)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color.htAccent)
                        }
                        .padding(.vertical, HTSpacing.xs)

                        Divider().background(Color.htBorder)

                        HStack {
                            Text(Strings.Catalog.weightLabel)
                                .font(HTTypography.body)
                            Spacer()
                            TextField("0", text: $weightText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            Picker("", selection: $weightUnit) {
                                ForEach(WeightUnit.allCases, id: \.self) { unit in
                                    Text(unit.displayName).tag(unit)
                                }
                            }
                            .pickerStyle(.menu)
                            .fixedSize()
                            .tint(Color.htAccent)
                        }
                        .padding(.vertical, HTSpacing.xs)
                    }
                    .htCard()
                }
                .padding(HTSpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
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
