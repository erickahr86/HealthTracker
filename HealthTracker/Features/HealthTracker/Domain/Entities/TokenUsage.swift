import Foundation

// MARK: - TokenUsage

struct TokenUsage: Hashable {
    var inputTokens: Int
    var outputTokens: Int

    var totalTokens: Int { inputTokens + outputTokens }
}
