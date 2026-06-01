import SwiftUI

// MARK: - MeasurementsSectionView
// Unit preferences: hydration (active) + placeholders for future fields.

struct MeasurementsSectionView: View {

    @Bindable var vm: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(Strings.Settings.measurementsSection, systemImage: "ruler")

            HStack {
                Text(Strings.Settings.hydrationUnitLabel)
                    .font(HTTypography.body)
                Spacer(minLength: HTSpacing.md)
                Picker("", selection: $vm.hydrationUnit) {
                    ForEach(HydrationUnit.allCases, id: \.self) { unit in
                        Text("\(unit.displayName) (\(unit.shortLabel))").tag(unit)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color.htAccent)
            }
            .padding(.vertical, HTSpacing.xs)
            .onChange(of: vm.hydrationUnit) { vm.updateHydrationUnit(vm.hydrationUnit) }

            Divider().background(Color.htBorder)

            Text(Strings.Settings.measurementsFooter)
                .font(HTTypography.caption)
                .foregroundStyle(.secondary)
        }
        .htCard()
    }
}
