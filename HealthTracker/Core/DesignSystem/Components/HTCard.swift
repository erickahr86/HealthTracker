import SwiftUI

// MARK: - HTCard
// Base card container. Wraps any content with the standard card style.

struct HTCard<Content: View>: View {

    private let padding: CGFloat
    private let content: () -> Content

    init(
        padding: CGFloat = HTSpacing.md,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(padding)
        .htCard()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: HTSpacing.md) {
        HTCard {
            Text("Sample card content")
                .font(HTTypography.body)
        }
        HTCard(padding: HTSpacing.lg) {
            VStack(alignment: .leading, spacing: HTSpacing.xs) {
                Text("Title").font(HTTypography.headline)
                Text("Subtitle").font(HTTypography.caption).foregroundStyle(.secondary)
            }
        }
    }
    .padding(HTSpacing.md)
    .background(Color.htBackground)
}
