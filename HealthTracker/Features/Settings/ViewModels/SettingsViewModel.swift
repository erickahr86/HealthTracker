import Foundation
import Observation

// MARK: - SettingsViewModel

@MainActor
@Observable
final class SettingsViewModel {

    // MARK: - AI Provider

    var selectedProvider: AIProvider = .anthropic
    var apiKeyInput:      String     = ""
    var hasStoredKey:     Bool       = false
    var isSavingKey:      Bool       = false
    var keyFeedback:      KeyFeedback?

    enum KeyFeedback: Equatable {
        case saved
        case deleted
        case error(String)
    }

    // MARK: - Measurements

    var hydrationUnit: HydrationUnit = .deviceDefault

    // MARK: - Private

    private let aiProviderRepo:  any AIProviderRepository
    private let preferencesRepo: any UserPreferencesRepository
    private var feedbackTask:    Task<Void, Never>?

    // MARK: - Init

    init(container: AppContainer) {
        aiProviderRepo  = container.aiProviderRepository
        preferencesRepo = container.userPreferencesRepository
    }

    // MARK: - Load

    func loadData() {
        selectedProvider = aiProviderRepo.getCurrentProvider()
        refreshKeyStatus()
        hydrationUnit = preferencesRepo.getHydrationUnit()
    }

    // MARK: - Provider

    func onProviderChanged() {
        aiProviderRepo.setProvider(selectedProvider)
        apiKeyInput = ""
        keyFeedback = nil
        refreshKeyStatus()
    }

    // MARK: - API Key

    func saveAPIKey() {
        let trimmed = apiKeyInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isSavingKey = true
        defer { isSavingKey = false }
        do {
            try aiProviderRepo.saveAPIKey(trimmed, for: selectedProvider)
            apiKeyInput  = ""
            hasStoredKey = true
            scheduleFeedback(.saved)
        } catch {
            scheduleFeedback(.error(error.localizedDescription))
        }
    }

    func deleteAPIKey() {
        do {
            try aiProviderRepo.deleteAPIKey(for: selectedProvider)
            hasStoredKey = false
            scheduleFeedback(.deleted)
        } catch {
            scheduleFeedback(.error(error.localizedDescription))
        }
    }

    // MARK: - Measurements

    func updateHydrationUnit(_ unit: HydrationUnit) {
        hydrationUnit = unit
        preferencesRepo.setHydrationUnit(unit)
    }

    // MARK: - About

    var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(v) (\(b))"
    }

    // MARK: - Helpers

    private func refreshKeyStatus() {
        hasStoredKey = (try? aiProviderRepo.getAPIKey(for: selectedProvider)) != nil
    }

    /// Shows a non-error feedback message, then clears it after 2 s.
    private func scheduleFeedback(_ feedback: KeyFeedback) {
        keyFeedback = feedback
        guard feedback != .error("") else { return }  // errors stay until dismissed

        feedbackTask?.cancel()
        feedbackTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            // Only auto-clear non-error feedback
            if case .error = self?.keyFeedback { return }
            self?.keyFeedback = nil
        }
    }
}
