import Foundation

// MARK: - AnalysisResult

struct AnalysisResult: Identifiable {
    let id: UUID
    var rawText: String
    var trafficLight: TrafficLight
    var tokenUsage: TokenUsage?
    var model: AIModel
    var createdAt: Date

    init(
        id: UUID = UUID(),
        rawText: String,
        trafficLight: TrafficLight,
        tokenUsage: TokenUsage? = nil,
        model: AIModel = .claudeSonnet,
        createdAt: Date = Date()
    ) {
        self.id           = id
        self.rawText      = rawText
        self.trafficLight = trafficLight
        self.tokenUsage   = tokenUsage
        self.model        = model
        self.createdAt    = createdAt
    }
}
