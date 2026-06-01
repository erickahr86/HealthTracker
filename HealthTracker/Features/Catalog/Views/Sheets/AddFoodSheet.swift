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
            ScrollView {
                VStack(spacing: HTSpacing.md) {
                    VStack(alignment: .leading, spacing: HTSpacing.sm) {
                        HStack {
                            Text(Strings.Catalog.nameLabel)
                                .font(HTTypography.body)
                            Spacer()
                            TextField(Strings.Catalog.foodNamePlaceholder, text: $name)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.words)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.vertical, HTSpacing.xs)

                        Divider().background(Color.htBorder)

                        HStack {
                            Text(Strings.Catalog.unitLabel)
                                .font(HTTypography.body)
                            Spacer()
                            TextField(Strings.Catalog.unitPlaceholder, text: $unit)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.vertical, HTSpacing.xs)

                        Divider().background(Color.htBorder)

                        HStack {
                            Text(Strings.Catalog.categoryLabel)
                                .font(HTTypography.body)
                            Spacer()
                            Picker("", selection: $category) {
                                ForEach(FoodCategory.allCases, id: \.self) { cat in
                                    Text(cat.displayName).tag(cat)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color.htAccent)
                        }
                        .padding(.vertical, HTSpacing.xs)

                        Divider().background(Color.htBorder)

                        HStack {
                            Text(Strings.Catalog.amountLabel)
                                .font(HTTypography.body)
                            Spacer()
                            TextField("0", text: $amountText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                        .padding(.vertical, HTSpacing.xs)
                    }
                    .htCard()
                }
                .padding(HTSpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
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
