import Foundation

// MARK: - AnalysisResult

struct AnalysisResult: Identifiable {
    let id: UUID
    var rawText: String
    var trafficLight: TrafficLight
    var metabolicSection: String?
    var functionalSection: String?
    var longevitySection: String?
    var missionSection: String?
    var tokenUsage: TokenUsage?
    var model: AIModel
    var createdAt: Date

    init(
        id: UUID = UUID(),
        rawText: String,
        trafficLight: TrafficLight,
        metabolicSection: String? = nil,
        functionalSection: String? = nil,
        longevitySection: String? = nil,
        missionSection: String? = nil,
        tokenUsage: TokenUsage? = nil,
        model: AIModel = .claudeSonnet,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.rawText = rawText
        self.trafficLight = trafficLight
        self.metabolicSection = metabolicSection
        self.functionalSection = functionalSection
        self.longevitySection = longevitySection
        self.missionSection = missionSection
        self.tokenUsage = tokenUsage
        self.model = model
        self.createdAt = createdAt
    }
}
