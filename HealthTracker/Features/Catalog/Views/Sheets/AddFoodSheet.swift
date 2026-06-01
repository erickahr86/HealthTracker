import SwiftUI

// MARK: - AddFoodSheet
// Modal form for creating a new custom food item.

struct AddFoodSheet: View {

    @Environment(\.dismiss) private var dismiss

    let onSave: (String, String, Double, FoodCategory) async -> Void

    @State private var name        = ""
    @State private var unit        = ""
    @State private var amountText  = ""
    @State private var category    = FoodCategory.other
    @State private var isSaving    = false

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !unit.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // Name
                Section {
                    TextField(Strings.Catalog.foodNamePlaceholder, text: $name)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                } header: {
                    Text(Strings.Catalog.nameLabel)
                }

                // Unit
                Section {
                    TextField(Strings.Catalog.unitPlaceholder, text: $unit)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } header: {
                    Text(Strings.Catalog.unitLabel)
                }

                // Category
                Section {
                    Picker(Strings.Catalog.categoryLabel, selection: $category) {
                        ForEach(FoodCategory.allCases, id: \.self) { cat in
                            Text(cat.displayName).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text(Strings.Catalog.categoryLabel)
                }

                // Default amount
                Section {
                    TextField("0", text: $amountText)
                        .keyboardType(.decimalPad)
                } header: {
                    Text(Strings.Catalog.amountLabel)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollContentBackground(.hidden)
            .background(Color.htBackground.ignoresSafeArea())
            .navigationTitle(Strings.Catalog.addFood)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(Strings.Catalog.cancel) { dismiss() }
                        .tint(Color.htAccent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(Strings.Catalog.save) {
                        let amount = Double(
                            amountText.replacingOccurrences(of: ",", with: ".")
                        ) ?? 0
                        isSaving = true
                        Task {
                            await onSave(
                                name.trimmingCharacters(in: .whitespaces),
                                unit.trimmingCharacters(in: .whitespaces),
                                amount,
                                category
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
    AddFoodSheet { _, _, _, _ in }
}
