import Foundation

// MARK: - AIProvider

enum AIProvider: String, Codable, CaseIterable, Hashable {
    case anthropic
    case openAI
    case gemini

    var displayName: String {
        switch self {
        case .anthropic: return "Anthropic"
        case .openAI:    return "OpenAI"
        case .gemini:    return "Gemini"
        }
    }
}

// MARK: - AIModel

struct AIModel: Identifiable, Hashable {
    let id: String
    var provider: AIProvider
    var displayName: String
}

// MARK: - Defaults

extension AIModel {
    static let claudeSonnet = AIModel(
        id: "claude-sonnet-4-20250514",
        provider: .anthropic,
        displayName: "Claude Sonnet 4"
    )
}
