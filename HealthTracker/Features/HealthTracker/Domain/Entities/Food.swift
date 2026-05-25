import Foundation

// MARK: - Food

struct Food: Identifiable, Hashable {
    let id: UUID
    var name: String
    var unit: String
    var defaultAmount: Double
    var isCustom: Bool

    init(
        id: UUID = UUID(),
        name: String,
        unit: String,
        defaultAmount: Double,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.unit = unit
        self.defaultAmount = defaultAmount
        self.isCustom = isCustom
    }
}
