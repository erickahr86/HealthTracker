import SwiftUI

// MARK: - UserProfileView
// Health profile form: personal data, body metrics, chronic conditions,
// fitness goals. All fields are optional — the AI prompt degrades gracefully
// when data is missing.

struct UserProfileView: View {

    @State private var vm: UserProfileViewModel

    // String buffers for numeric text fields (avoid direct Double binding issues)
    @State private var heightText    = ""
    @State private var weightText    = ""
    @State private var bodyFatText   = ""
    @State private var birthYearText = ""

    // True when the user prefers metric units.
    // Drives both the weight (kg/lbs) and height (cm/in) suffixes.
    private var isMetric: Bool { vm.preferences.preferredWeightUnit == .kg }

    init(repository: any UserPreferencesRepository) {
        let viewModel = UserProfileViewModel(repository: repository)
        _vm = State(wrappedValue: viewModel)
    }

    var body: some View {
        @Bindable var vm = vm

        Form {
            personalSection
            bodySection
            healthSection
            goalsSection
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(Strings.UserProfile.title)
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .background(Color.htBackground.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                saveButton
            }
        }
        .onAppear { loadTextBuffers() }
        .onChange(of: vm.isSaved) { _, saved in
            if saved {
                // Reset flag after brief feedback delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    vm.isSaved = false
                }
            }
        }
    }

    // MARK: - Save button

    private var saveButton: some View {
        Button {
            flushTextBuffers()
            vm.save()
        } label: {
            Text(vm.isSaved ? Strings.UserProfile.saved : Strings.UserProfile.save)
                .foregroundStyle(vm.isSaved ? Color.green : Color.htAccent)
                .fontWeight(.semibold)
                .animation(.easeInOut, value: vm.isSaved)
        }
    }

    // MARK: - Personal section

    private var personalSection: some View {
        Section {
            // Name
            HStack {
                Text(Strings.UserProfile.nameLabel)
                Spacer()
                TextField(Strings.UserProfile.namePlaceholder, text: Binding(
                    get: { vm.preferences.name ?? "" },
                    set: { vm.preferences.name = $0.isEmpty ? nil : $0 }
                ))
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
            }

            // Biological sex
            Picker(Strings.UserProfile.sexLabel, selection: Binding(
                get: { vm.preferences.biologicalSex },
                set: { vm.preferences.biologicalSex = $0 }
            )) {
                Text(Strings.UserProfile.notSpecified).tag(Optional<BiologicalSex>.none)
                ForEach(BiologicalSex.allCases, id: \.self) { sex in
                    Text(sex.displayName).tag(Optional(sex))
                }
            }

            // Birth year
            HStack {
                Text(Strings.UserProfile.birthYearLabel)
                Spacer()
                TextField(Strings.UserProfile.birthYearPlaceholder, text: $birthYearText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
                    .frame(width: 80)

                if let age = vm.computedAge {
                    Text("(\(age) \(Strings.UserProfile.yearsOld))")
                        .font(HTTypography.caption)
                        .foregroundStyle(.secondary)
                }
            }

        } header: {
            Text(Strings.UserProfile.personalSection)
        }
    }

    // MARK: - Body section

    private var bodySection: some View {
        Section {
            // Height
            HStack {
                Text(Strings.UserProfile.heightLabel)
                Spacer()
                TextField(Strings.UserProfile.heightPlaceholder, text: $heightText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
                    .frame(width: 80)
                Text(isMetric ? "cm" : "in")
                    .foregroundStyle(.secondary)
                    .font(HTTypography.caption)
            }

            // Weight
            HStack {
                Text(Strings.UserProfile.weightLabel)
                Spacer()
                TextField(Strings.UserProfile.weightPlaceholder, text: $weightText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
                    .frame(width: 80)
                Text(vm.preferences.preferredWeightUnit.displayName)
                    .foregroundStyle(.secondary)
                    .font(HTTypography.caption)
            }

            // Body fat
            HStack {
                Text(Strings.UserProfile.bodyFatLabel)
                Spacer()
                TextField(Strings.UserProfile.bodyFatPlaceholder, text: $bodyFatText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
                    .frame(width: 80)
                Text("%")
                    .foregroundStyle(.secondary)
                    .font(HTTypography.caption)
            }

            // Preferred weight unit — changing it also reconverts height / weight text buffers
            Picker(Strings.UserProfile.weightUnitLabel, selection: Binding(
                get: { vm.preferences.preferredWeightUnit },
                set: { vm.preferences.preferredWeightUnit = $0 }
            )) {
                ForEach(WeightUnit.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            .onChange(of: vm.preferences.preferredWeightUnit) { old, new in
                reconvertUnits(from: old, to: new)
            }

        } header: {
            Text(Strings.UserProfile.bodySection)
        }
    }

    // MARK: - Health section

    private var healthSection: some View {
        Section {
            // Chronic conditions chip grid
            if !ChronicCondition.allCases.isEmpty {
                VStack(alignment: .leading, spacing: HTSpacing.xs) {
                    Text(Strings.UserProfile.conditionsLabel)
                        .font(HTTypography.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, HTSpacing.xs)

                    WrapLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                        ForEach(ChronicCondition.allCases, id: \.self) { condition in
                            SelectableChipView(
                                label:      condition.displayName,
                                isSelected: vm.preferences.chronicConditions.contains(condition),
                                onToggle:   { vm.toggleCondition(condition) }
                            )
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: HTSpacing.sm, leading: HTSpacing.md,
                                         bottom: HTSpacing.sm, trailing: HTSpacing.md))
            }

            // Medications free text
            VStack(alignment: .leading, spacing: HTSpacing.xs) {
                Text(Strings.UserProfile.medicationsLabel)
                    .font(HTTypography.subheadline)
                    .foregroundStyle(.secondary)

                TextField(
                    Strings.UserProfile.medicationsPlaceholder,
                    text: Binding(
                        get: { vm.preferences.medications ?? "" },
                        set: { vm.preferences.medications = $0.isEmpty ? nil : $0 }
                    ),
                    axis: .vertical
                )
                .font(HTTypography.body)
                .lineLimit(2...4)
            }

        } header: {
            Text(Strings.UserProfile.healthSection)
        } footer: {
            Text(Strings.UserProfile.healthFooter)
        }
    }

    // MARK: - Goals section

    private var goalsSection: some View {
        Section {
            // Fitness goals chip grid
            VStack(alignment: .leading, spacing: HTSpacing.xs) {
                Text(Strings.UserProfile.goalsLabel)
                    .font(HTTypography.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, HTSpacing.xs)

                WrapLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                    ForEach(FitnessGoal.allCases, id: \.self) { goal in
                        SelectableChipView(
                            label:      goal.displayName,
                            isSelected: vm.preferences.fitnessGoals.contains(goal),
                            onToggle:   { vm.toggleGoal(goal) }
                        )
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: HTSpacing.sm, leading: HTSpacing.md,
                                     bottom: HTSpacing.sm, trailing: HTSpacing.md))

            // Training frequency
            Stepper(value: Binding(
                get: { vm.preferences.trainingDaysPerWeek ?? 3 },
                set: { vm.preferences.trainingDaysPerWeek = $0 }
            ), in: 1...7) {
                HStack {
                    Text(Strings.UserProfile.trainingDaysLabel)
                    Spacer()
                    Text("\(vm.preferences.trainingDaysPerWeek ?? 3)")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            }

        } header: {
            Text(Strings.UserProfile.goalsSection)
        } footer: {
            Text(Strings.UserProfile.goalsFooter)
        }
    }

    // MARK: - Text buffer helpers
    // Canonical storage is always metric (kg, cm).
    // Display converts to the user's preferred unit and back.

    private func loadTextBuffers() {
        let prefs = vm.preferences
        heightText    = prefs.heightCm.map    { formatDouble(isMetric ? $0 : $0 / 2.54) } ?? ""
        weightText    = prefs.weightKg.map    { formatDouble(isMetric ? $0 : $0 * 2.20462) } ?? ""
        bodyFatText   = prefs.bodyFatPercent.map { formatDouble($0) } ?? ""
        birthYearText = prefs.birthYear.map   { String($0) } ?? ""
    }

    /// Writes text buffer values back into the view model (always stored as kg / cm).
    private func flushTextBuffers() {
        if let h = Double(heightText) {
            vm.preferences.heightCm = isMetric ? h : h * 2.54
        } else {
            vm.preferences.heightCm = nil
        }
        if let w = Double(weightText) {
            vm.preferences.weightKg = isMetric ? w : w / 2.20462
        } else {
            vm.preferences.weightKg = nil
        }
        vm.preferences.bodyFatPercent = Double(bodyFatText)
        vm.preferences.birthYear      = Int(birthYearText)
    }

    /// Called when the user changes the unit picker mid-session so text buffers stay consistent.
    private func reconvertUnits(from old: WeightUnit, to new: WeightUnit) {
        guard old != new else { return }
        let toMetric = (new == .kg)

        if let w = Double(weightText) {
            weightText = formatDouble(toMetric ? w / 2.20462 : w * 2.20462)
        }
        if let h = Double(heightText) {
            heightText = formatDouble(toMetric ? h * 2.54 : h / 2.54)
        }
    }

    private func formatDouble(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        UserProfileView(
            repository: UserPreferencesRepositoryImpl(
                defaults: UserDefaults(suiteName: "preview")!
            )
        )
    }
    .preferredColorScheme(.dark)
}
