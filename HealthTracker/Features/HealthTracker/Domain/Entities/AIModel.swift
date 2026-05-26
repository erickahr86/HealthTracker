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

    /// Placeholder shown in the API key SecureField.
    var apiKeyPlaceholder: String {
        switch self {
        case .anthropic: return "sk-ant-api03-..."
        case .openAI:    return "sk-..."
        case .gemini:    return "AIza..."
        }
    }

    /// URL of the provider's API key management console.
    var consoleURL: URL {
        switch self {
        case .anthropic: return URL(string: "https://console.anthropic.com")!
        case .openAI:    return URL(string: "https://platform.openai.com/api-keys")!
        case .gemini:    return URL(string: "https://aistudio.google.com/app/apikey")!
        }
    }

    /// Short domain label shown in the footer link.
    var consoleLabel: String {
        switch self {
        case .anthropic: return "console.anthropic.com"
        case .openAI:    return "platform.openai.com"
        case .gemini:    return "aistudio.google.com"
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
        id:          "claude-sonnet-4-20250514",
        provider:    .anthropic,
        displayName: "Claude Sonnet 4"
    )

    static let geminiFlash = AIModel(
        id:          "gemini-2.0-flash",
        provider:    .gemini,
        displayName: "Gemini 2.0 Flash"
    )
}
