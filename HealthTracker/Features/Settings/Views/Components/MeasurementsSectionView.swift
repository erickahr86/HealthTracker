import SwiftUI

// MARK: - MeasurementsSectionView
// Unit preferences: hydration (active) + placeholders for future weight / profile fields.

struct MeasurementsSectionView: View {

    @Bindable var vm: SettingsViewModel

    var body: some View {
        Section {
            // Hydration unit picker
            Picker(Strings.Settings.hydrationUnitLabel, selection: $vm.hydrationUnit) {
                ForEach(HydrationUnit.allCases, id: \.self) { unit in
                    HStack {
                        Text(unit.displayName)
                        Spacer()
                        Text(unit.shortLabel)
                            .foregroundStyle(.secondary)
                    }
                    .tag(unit)
                }
            }
            .onChange(of: vm.hydrationUnit) { vm.updateHydrationUnit(vm.hydrationUnit) }

        } header: {
            Text(Strings.Settings.measurementsSection)
        } footer: {
            Text(Strings.Settings.measurementsFooter)
        }
    }
}
