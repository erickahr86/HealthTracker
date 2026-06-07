import Foundation

// MARK: - AnthropicError

enum AnthropicError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:                          return Strings.Error.invalidURL
        case .invalidResponse:                     return Strings.Error.invalidResponse
        case .apiError(let code, let message):     return Strings.Error.api(statusCode: code, message: message)
        case .decodingError(let error):            return Strings.Error.decoding(error)
        case .networkError(let error):             return Strings.Error.network(error)
        }
    }
}

// MARK: - AnthropicAPIClient

final class AnthropicAPIClient: LLMProvider {

    // MARK: - Constants

    private enum API {
        static let endpoint       = "https://api.anthropic.com/v1/messages"
        static let version        = "2023-06-01"
        static let maxTokens      = 4000
    }

    // MARK: - LLMProvider

    var model: AIModel { .claudeSonnet }

    // MARK: - Dependencies

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - LLMProvider

    func analyze(report: DailyReport, apiKey: String, systemPrompt: String, hydrationUnit: HydrationUnit) async throws -> AnalysisResult {
        let urlRequest = try buildURLRequest(for: report, apiKey: apiKey, systemPrompt: systemPrompt, hydrationUnit: hydrationUnit)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw AnthropicError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw AnthropicError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let errorMsg = (try? JSONDecoder().decode(AnthropicErrorResponse.self, from: data))?.error.message
                ?? "Sin detalles"
            throw AnthropicError.apiError(statusCode: http.statusCode, message: errorMsg)
        }

        do {
            let apiResponse = try JSONDecoder().decode(AnthropicResponse.self, from: data)
            return AnthropicMapper.toAnalysisResult(apiResponse)
        } catch {
            throw AnthropicError.decodingError(error)
        }
    }

    // MARK: - Private

    private func buildURLRequest(for report: DailyReport, apiKey: String, systemPrompt: String, hydrationUnit: HydrationUnit) throws -> URLRequest {
        guard let url = URL(string: API.endpoint) else { throw AnthropicError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey,             forHTTPHeaderField: "x-api-key")
        request.setValue(API.version,        forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = AnthropicRequest(
            model: model.id,
            maxTokens: API.maxTokens,
            system: systemPrompt,
            messages: [
                AnthropicMessage(
                    role: "user",
                    content: buildContentBlocks(for: report, hydrationUnit: hydrationUnit)
                )
            ]
        )

        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    /// Builds content blocks: images first (meal photos), then the text report.
    private func buildContentBlocks(for report: DailyReport, hydrationUnit: HydrationUnit) -> [AnthropicContentBlock] {
        var blocks: [AnthropicContentBlock] = []

        for log in report.mealLogs {
            if let data = log.photoData {
                blocks.append(.image(mediaType: "image/jpeg", base64Data: data.base64EncodedString()))
            }
        }

        blocks.append(.text(ReportFormatter.format(report, hydrationUnit: hydrationUnit)))
        return blocks
    }
}
