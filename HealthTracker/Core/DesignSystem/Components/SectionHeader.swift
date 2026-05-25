import SwiftUI

// MARK: - SectionHeader
// Uniform section title used across all cards and screens.

struct SectionHeader: View {

    let title: String
    let systemImage: String?
    var action: (() -> Void)?
    var actionLabel: String?

    init(
        _ title: String,
        systemImage: String? = nil,
        actionLabel: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title       = title
        self.systemImage = systemImage
        self.actionLabel = actionLabel
        self.action      = action
    }

    var body: some View {
        HStack(spacing: HTSpacing.xs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: HTDimensions.Icon.sm, weight: .semibold))
                    .foregroundStyle(Color.htAccent)
            }

            Text(title)
                .font(HTTypography.title3)
                .foregroundStyle(.primary)

            Spacer()

            if let action, let label = actionLabel {
                Button(action: action) {
                    HStack(spacing: HTSpacing.xxs) {
                        Image(systemName: "plus")
                        Text(label)
                    }
                    .font(HTTypography.subheadline)
                    .foregroundStyle(Color.htAccent)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: HTSpacing.lg) {
        SectionHeader("Physical Activity", systemImage: "figure.strengthtraining.traditional")
        SectionHeader("Exercises",
                      systemImage: "dumbbell",
                      actionLabel: "Add",
                      action: { })
    }
    .padding(HTSpacing.md)
    .background(Color.htBackground)
}
