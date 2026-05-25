import SwiftUI

// MARK: - HealthIndicatorsSectionView
// Optional glucose and blood pressure fields.

struct HealthIndicatorsSectionView: View {

    @Bindable var vm: DailyReportViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(Strings.Today.healthSection,
                          systemImage: "stethoscope")

            FieldRow(label: Strings.Today.glucoseLabel,
                     systemImage: "drop.fill") {
                TextField(
                    Strings.Today.glucosePlaceholder,
                    text: glucoseText,
                    prompt: Text(Strings.Today.glucosePlaceholder)
                )
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .font(HTTypography.body)
            }

            Divider().background(Color.htBorder)

            FieldRow(label: Strings.Today.bpLabel,
                     systemImage: "heart.fill") {
                TextField(
                    Strings.Today.bpPlaceholder,
                    text: bpText,
                    prompt: Text(Strings.Today.bpPlaceholder)
                )
                .keyboardType(.numbersAndPunctuation)
                .multilineTextAlignment(.trailing)
                .font(HTTypography.body)
            }
        }
        .htCard()
    }

    // MARK: - Bindings

    private var glucoseText: Binding<String> {
        Binding(
            get: { vm.report.glucoseMgdl.map(String.init) ?? "" },
            set: { vm.report.glucoseMgdl = $0.isEmpty ? nil : Int($0) }
        )
    }

    private var bpText: Binding<String> {
        Binding(
            get: { vm.report.bloodPressure ?? "" },
            set: { vm.report.bloodPressure = $0.isEmpty ? nil : $0 }
        )
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var vm = DailyReportViewModel(factory: AppContainer.preview.featureFactory)
    HealthIndicatorsSectionView(vm: vm)
        .padding(HTSpacing.md)
        .background(Color.htBackground)
}
