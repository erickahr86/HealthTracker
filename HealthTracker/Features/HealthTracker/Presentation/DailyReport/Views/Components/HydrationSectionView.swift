import SwiftUI

// MARK: - HydrationSectionView
// Water intake counter with adaptive drop icons.
// The unit (glass size / bottle) is read from UserPreferences and
// auto-detected from the device locale on first launch.

struct HydrationSectionView: View {

    @Bindable var vm: DailyReportViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: HTSpacing.sm) {
            SectionHeader(Strings.Today.hydrationSection,
                          systemImage: "drop.fill")

            dropRow
            infoRow
        }
        .htCard()
    }

    // MARK: - Drop row

    private var dropRow: some View {
        let unit     = vm.hydrationUnit
        let maxCount = unit.maxCount
        let current  = vm.report.waterGlasses

        return HStack(spacing: 0) {
            // Tappable drops — each tap sets the level to that index.
            // Tapping the already-filled last drop decrements by 1.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: HTSpacing.xs) {
                    ForEach(1...maxCount, id: \.self) { index in
                        Button {
                            vm.report.waterGlasses = (current == index)
                                ? index - 1
                                : index
                        } label: {
                            Image(systemName: index <= current ? "drop.fill" : "drop")
                                .font(.system(size: dropIconSize(for: unit)))
                                .foregroundStyle(
                                    index <= current
                                        ? Color.htAccent
                                        : Color.secondary.opacity(0.35)
                                )
                        }
                        .buttonStyle(.plain)
                        .animation(.easeInOut(duration: 0.15), value: current)
                    }
                }
            }

            // Numeric count badge
            Text("\(current)")
                .font(HTTypography.title2)
                .foregroundStyle(Color.htAccent)
                .frame(minWidth: 36, alignment: .trailing)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: current)
        }
    }

    // MARK: - Info row

    private var infoRow: some View {
        let unit    = vm.hydrationUnit
        let current = vm.report.waterGlasses

        return HStack(spacing: HTSpacing.xs) {
            Text(unit.shortLabel)
                .font(HTTypography.captionBold)
                .foregroundStyle(Color.htAccent)

            Text("·")
                .foregroundStyle(.secondary)

            if current > 0 {
                Text(unit.formattedTotalVolume(count: current))
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: current)
            } else {
                Text("\(unit.maxCount) \(Strings.Today.waterGlassesUnit)")
                    .font(HTTypography.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Helpers

    /// Scales the drop icon slightly based on unit size so larger units feel bigger.
    private func dropIconSize(for unit: HydrationUnit) -> CGFloat {
        switch unit {
        case .glass8oz, .ml250:           return 20
        case .glass16oz, .ml500:          return 22
        case .glass40oz, .liter:          return 26
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var vm = DailyReportViewModel(factory: AppContainer.preview.featureFactory)
    VStack(spacing: HTSpacing.md) {
        HydrationSectionView(vm: vm)
    }
    .padding(HTSpacing.md)
    .background(Color.htBackground)
}
