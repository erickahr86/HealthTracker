import SwiftUI

// MARK: - WrapLayout
// A Layout that places child views left-to-right, wrapping to a new row
// whenever the next item doesn't fit the available width.
// Use it for chip / tag collections where items have variable intrinsic widths.

struct WrapLayout: Layout {

    var horizontalSpacing: CGFloat
    var verticalSpacing: CGFloat

    init(horizontalSpacing: CGFloat = 8, verticalSpacing: CGFloat = 8) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing   = verticalSpacing
    }

    // MARK: - Layout

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let rows = makeRows(width: proposal.width ?? 320, subviews: subviews)
        let height = rows.map(\.height).reduce(0, +)
                   + CGFloat(max(rows.count - 1, 0)) * verticalSpacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = makeRows(width: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                let size = item.subview.sizeThatFits(.unspecified)
                item.subview.place(
                    at: CGPoint(x: x, y: y + (row.height - size.height) / 2),
                    proposal: .unspecified
                )
                x += size.width + horizontalSpacing
            }
            y += row.height + verticalSpacing
        }
    }

    // MARK: - Private helpers

    private struct Row {
        struct Item { let subview: LayoutSubview }
        var items:  [Item]   = []
        var width:  CGFloat  = 0
        var height: CGFloat  = 0
    }

    private func makeRows(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var row  = Row()

        for subview in subviews {
            let size      = subview.sizeThatFits(.unspecified)
            let addWidth  = row.items.isEmpty ? size.width : row.width + horizontalSpacing + size.width

            if !row.items.isEmpty && addWidth > width {
                rows.append(row)
                row = Row()
            }

            row.items.append(Row.Item(subview: subview))
            row.width  = row.items.count == 1 ? size.width : row.width + horizontalSpacing + size.width
            row.height = max(row.height, size.height)
        }

        if !row.items.isEmpty { rows.append(row) }
        return rows
    }
}
