import Foundation

// MARK: - AIProviderRepositoryImpl

final class AIProviderRepositoryImpl: AIProviderRepository {

    // MARK: - Constants

    private enum Keys {
        static let currentProvider = "healthtracker.ai.currentProvider"

        static func apiKey(for provider: AIProvider) -> String {
            "healthtracker.apikey.\(provider.rawValue)"
        }
    }

    // MARK: - Dependencies

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - AIProviderRepository

    func getCurrentProvider() -> AIProvider {
        guard let raw = userDefaults.string(forKey: Keys.currentProvider),
              let provider = AIProvider(rawValue: raw) else {
            return .anthropic   // default
        }
        return provider
    }

    func setProvider(_ provider: AIProvider) {
        userDefaults.set(provider.rawValue, forKey: Keys.currentProvider)
    }

    func getAPIKey(for provider: AIProvider) throws -> String {
        try KeychainService.get(key: Keys.apiKey(for: provider))
    }

    func saveAPIKey(_ key: String, for provider: AIProvider) throws {
        try KeychainService.save(key: Keys.apiKey(for: provider), value: key)
    }

    func deleteAPIKey(for provider: AIProvider) throws {
        try KeychainService.delete(key: Keys.apiKey(for: provider))
    }
}
