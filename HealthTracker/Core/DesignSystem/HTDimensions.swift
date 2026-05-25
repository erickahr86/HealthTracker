import CoreFoundation

// MARK: - HTDimensions
// Fixed size constants: radii, borders, icons, interactive elements.

enum HTDimensions {

    enum CornerRadius {
        static let sm:   CGFloat =  8
        static let md:   CGFloat = 12
        static let card: CGFloat = 16   // spec default for all cards
        static let lg:   CGFloat = 20
        static let pill: CGFloat = 999  // fully rounded
    }

    enum Border {
        static let hairline: CGFloat = 0.5
        static let regular:  CGFloat = 1.0
    }

    enum Icon {
        static let sm:  CGFloat = 16
        static let md:  CGFloat = 24
        static let lg:  CGFloat = 32
        static let xl:  CGFloat = 48
    }

    enum Button {
        static let height:    CGFloat = 56
        static let minWidth:  CGFloat = 200
        static let iconSize:  CGFloat = 20
    }

    enum TrafficLight {
        static let dotSize:     CGFloat = 10
        static let badgeHeight: CGFloat = 28
    }
}
