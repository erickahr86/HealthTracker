import SwiftUI

// MARK: - ActivitySectionView
// Rest day toggle, steps, energy level, sleep hours.

struct ActivitySectionView: View {

    @Bindable var vm: DailyReportViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(
                Strings.Today.activitySection,
                systemImage: "figure.walk"
            )

            // Rest day toggle
            Toggle(Strings.Today.restDay, isOn: $vm.report.isRestDay)
                .font(HTTypography.body)
                .tint(Color.htAccent)

            Divider().background(Color.htBorder)

            // Steps
            FieldRow(
                label: Strings.Today.stepsLabel,
                systemImage: "shoeprints.fill"
            ) {
                HStack(spacing: HTSpacing.xs) {
                    TextField(
                        Strings.Today.stepsPlaceholder,
                        text: stepsText,
                        prompt: Text(Strings.Today.stepsPlaceholder)
                    )
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(HTTypography.body)

                    if vm.isHealthKitAvailable {
                        Button {
                            Task {
                                vm.report.steps = nil
                                await vm.syncFromHealthKit()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.htAccent)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Divider().background(Color.htBorder)

            // Energy level (1–5)
            VStack(alignment: .leading, spacing: HTSpacing.xxs) {
                Text(Strings.Today.energyLabel)
                    .font(HTTypography.subheadline)
                    .foregroundStyle(.secondary)
                EnergyPicker(level: $vm.report.energyLevel)
            }

            Divider().background(Color.htBorder)

            // Sleep
            FieldRow(
                label: Strings.Today.sleepLabel,
                systemImage: "moon.zzz.fill"
            ) {
                TextField(
                    Strings.Today.sleepPlaceholder,
                    text: sleepText,
                    prompt: Text(Strings.Today.sleepPlaceholder)
                )
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(HTTypography.body)
            }

        }
        .htCard()
    }

    // MARK: - Bindings over optionals

    private var stepsText: Binding<String> {
        Binding(
            get: { vm.report.steps.map(String.init) ?? "" },
            set: { vm.report.steps = $0.isEmpty ? nil : Int($0) }
        )
    }

    private var sleepText: Binding<String> {
        Binding(
            get: { vm.report.sleepHours ?? "" },
            set: { vm.report.sleepHours = $0.isEmpty ? nil : $0 }
        )
    }
}

// MARK: - EnergyPicker
// Five stars: tap to set level. Tap same level again to clear.

private struct EnergyPicker: View {

    @Binding var level: Int?

    var body: some View {
        HStack(spacing: HTSpacing.xs) {
            ForEach(1...5, id: \.self) { value in
                Button {
                    level = (level == value) ? nil : value
                } label: {
                    Image(
                        systemName: value <= (level ?? 0) ? "star.fill" : "star"
                    )
                    .font(.system(size: HTDimensions.Icon.md))
                    .foregroundStyle(
                        value <= (level ?? 0) ? Color.htAccent : Color.secondary
                    )
                }
                .buttonStyle(.plain)
            }
            Spacer()
            if let level {
                Text("\(level)/5")
                    .font(HTTypography.captionBold)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - FieldRow helper

struct FieldRow<Content: View>: View {

    let label: String
    let systemImage: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: HTSpacing.md) {
            Label(label, systemImage: systemImage)
                .font(HTTypography.body)
                .foregroundStyle(.primary)
                .labelStyle(.titleAndIcon)
            Spacer(minLength: HTSpacing.sm)
            content()
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var vm = DailyReportViewModel(
        factory: AppContainer.preview.featureFactory
    )
    ActivitySectionView(vm: vm)
        .padding(HTSpacing.xs)
        .background(Color.htBackground)
}
