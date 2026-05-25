import SwiftUI

// MARK: - HTButton
// Primary full-width CTA button.

struct HTButton: View {

    let title: String
    let systemImage: String?
    let isLoading: Bool
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    HStack(spacing: HTSpacing.xs) {
                        if let systemImage {
                            Image(systemName: systemImage)
                                .font(.system(size: HTDimensions.Button.iconSize, weight: .semibold))
                        }
                        Text(title)
                            .font(HTTypography.headline)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: HTDimensions.Button.height)
            .foregroundStyle(.white)
            .background(Color.htAccent)
            .clipShape(RoundedRectangle(cornerRadius: HTDimensions.CornerRadius.md))
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: HTSpacing.md) {
        HTButton("Analyze Clinical Report", systemImage: "chart.bar.doc.horizontal") { }
        HTButton("Loading...", isLoading: true) { }
    }
    .padding(HTSpacing.md)
    .background(Color.htBackground)
}
