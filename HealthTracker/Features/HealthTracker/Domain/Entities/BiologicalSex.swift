import Foundation

// MARK: - BiologicalSex

enum BiologicalSex: String, Codable, CaseIterable, Hashable {
    case male
    case female

    var displayName: String {
        NSLocalizedString("biological.sex.\(rawValue)", comment: "Biological sex label")
    }
}
