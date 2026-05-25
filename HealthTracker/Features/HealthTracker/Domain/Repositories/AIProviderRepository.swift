import Foundation

// MARK: - AIProviderRepository

protocol AIProviderRepository {
    func getCurrentProvider() -> AIProvider
    func setProvider(_ provider: AIProvider)
    func getAPIKey(for provider: AIProvider) throws -> String
    func saveAPIKey(_ key: String, for provider: AIProvider) throws
    func deleteAPIKey(for provider: AIProvider) throws
}
