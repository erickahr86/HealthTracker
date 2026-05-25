import SwiftUI

// MARK: - HTCardModifier

struct HTCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(HTSpacing.md)
            .background(Color.htSurface)
            .clipShape(RoundedRectangle(cornerRadius: HTDimensions.CornerRadius.card))
            .overlay(
                RoundedRectangle(cornerRadius: HTDimensions.CornerRadius.card)
                    .strokeBorder(Color.htBorder, lineWidth: HTDimensions.Border.regular)
            )
    }
}

// MARK: - View extension

extension View {
    /// Applies the standard HealthTracker card style:
    /// surface background, 16pt corner radius, subtle border.
    func htCard() -> some View {
        modifier(HTCardModifier())
    }
}
