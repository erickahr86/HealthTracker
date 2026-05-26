import SwiftUI

// MARK: - SelectableChipView
// Generic tappable pill chip for multi-select grids (conditions, goals, etc.)

struct SelectableChipView: View {

    let label:      String
    let isSelected: Bool
    let onToggle:   () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 5) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .transition(.scale.combined(with: .opacity))
                }
                Text(label)
                    .font(HTTypography.subheadlineBold)
            }
            .padding(.horizontal, HTSpacing.sm)
            .padding(.vertical, HTSpacing.xs)
            .background(isSelected ? Color.htAccent : Color.htSurfaceVariant)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .clipShape(Capsule())
            .overlay {
                Capsule().strokeBorder(
                    isSelected ? Color.htAccent : Color.htBorder,
                    lineWidth: HTDimensions.Border.regular
                )
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: HTSpacing.sm) {
        SelectableChipView(label: "Type 2 Diabetes", isSelected: true,  onToggle: {})
        SelectableChipView(label: "Hypertension",    isSelected: false, onToggle: {})
    }
    .padding()
    .background(Color.htBackground)
}
