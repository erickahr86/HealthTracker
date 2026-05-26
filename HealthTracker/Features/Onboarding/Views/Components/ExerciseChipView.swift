import SwiftUI

// MARK: - ExerciseChipView
// Tappable pill chip for the onboarding exercise selection screen.
// Selected state shows a filled accent background + checkmark prefix.

struct ExerciseChipView: View {

    let exercise:   OnboardingExercise
    let isSelected: Bool
    let action:     () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .transition(.scale.combined(with: .opacity))
                }
                Text(exercise.name)
                    .font(HTTypography.subheadline)
                    .lineLimit(1)
            }
            .padding(.horizontal, HTSpacing.sm)
            .padding(.vertical, HTSpacing.xs)
            .background(isSelected ? Color.htAccent : Color.htSurfaceVariant)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(
                        isSelected ? Color.htAccent : Color.htBorder,
                        lineWidth: HTDimensions.Border.regular
                    )
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Preview

#Preview {
    let gym = OnboardingExerciseCatalog.gym[0]
    VStack(spacing: HTSpacing.sm) {
        ExerciseChipView(exercise: gym, isSelected: false) { }
        ExerciseChipView(exercise: gym, isSelected: true)  { }
    }
    .padding()
    .background(Color.htBackground)
}
