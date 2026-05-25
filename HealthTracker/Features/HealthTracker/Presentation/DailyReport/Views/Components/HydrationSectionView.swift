import SwiftUI

// MARK: - HydrationSectionView
// Water glasses counter with visual drop indicators.

struct HydrationSectionView: View {

    @Bindable var vm: DailyReportViewModel

    private let maxGlasses = 12

    var body: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(Strings.Today.hydrationSection,
                          systemImage: "drop.fill")

            HStack(spacing: 0) {
                // Visual drops row (up to maxGlasses)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: HTSpacing.xs) {
                        ForEach(1...maxGlasses, id: \.self) { index in
                            Button {
                                let tapped = index
                                vm.report.waterGlasses = (vm.report.waterGlasses == tapped)
                                    ? tapped - 1
                                    : tapped
                            } label: {
                                Image(systemName: index <= vm.report.waterGlasses
                                      ? "drop.fill" : "drop")
                                    .font(.system(size: HTDimensions.Icon.md))
                                    .foregroundStyle(index <= vm.report.waterGlasses
                                        ? Color.htAccent : Color.secondary.opacity(0.4))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Count label
                Text("\(vm.report.waterGlasses)")
                    .font(HTTypography.title2)
                    .foregroundStyle(Color.htAccent)
                    .frame(minWidth: 36, alignment: .trailing)
            }

            Text(Strings.Today.waterGlassesUnit)
                .font(HTTypography.caption)
                .foregroundStyle(.secondary)
        }
        .htCard()
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var vm = DailyReportViewModel(factory: AppContainer.preview.featureFactory)
    HydrationSectionView(vm: vm)
        .padding(HTSpacing.md)
        .background(Color.htBackground)
}
