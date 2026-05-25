import Foundation

// MARK: - ProviderFactory
// Responsible for creating the correct LLMProvider based on the user's current selection.
// Adding a new AI provider only requires adding a case here — no other file changes.

final class ProviderFactory {

    private let aiProviderRepository: any AIProviderRepository

    init(aiProviderRepository: any AIProviderRepository) {
        self.aiProviderRepository = aiProviderRepository
    }

    func makeLLMProvider() -> any LLMProvider {
        switch aiProviderRepository.getCurrentProvider() {
        case .anthropic:
            return AnthropicAPIClient()
        case .openAI:
            // TODO: return OpenAIAPIClient() when implemented
            return AnthropicAPIClient()
        case .gemini:
            // TODO: return GeminiAPIClient() when implemented
            return AnthropicAPIClient()
        }
    }
}
