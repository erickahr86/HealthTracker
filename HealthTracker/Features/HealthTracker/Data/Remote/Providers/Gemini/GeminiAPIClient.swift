import Foundation

// MARK: - GeminiError

enum GeminiError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noContent
    case rateLimited                              // HTTP 429
    case apiError(statusCode: Int, message: String)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:                         return Strings.Error.invalidURL
        case .invalidResponse, .noContent:        return Strings.Error.invalidResponse
        case .rateLimited:                        return Strings.Error.geminiRateLimited
        case .apiError(let code, let message):    return Strings.Error.api(statusCode: code, message: message)
        case .decodingError(let error):           return Strings.Error.decoding(error)
        case .networkError(let error):            return Strings.Error.network(error)
        }
    }
}

// MARK: - GeminiAPIClient

final class GeminiAPIClient: LLMProvider {

    // MARK: - Constants

    private enum API {
        static let baseURL        = "https://generativelanguage.googleapis.com/v1beta/models"
        static let action         = "generateContent"
        static let maxOutputTokens = 1500
    }

    // MARK: - LLMProvider

    var model: AIModel { .geminiFlash }

    // MARK: - Dependencies

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - LLMProvider

    func analyze(
        report:        DailyReport,
        apiKey:        String,
        systemPrompt:  String,
        hydrationUnit: HydrationUnit
    ) async throws -> AnalysisResult {
        let urlRequest = try buildURLRequest(
            for: report,
            apiKey: apiKey,
            systemPrompt: systemPrompt,
            hydrationUnit: hydrationUnit
        )

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw GeminiError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            if http.statusCode == 429 { throw GeminiError.rateLimited }
            let errorMsg = (try? JSONDecoder().decode(GeminiErrorResponse.self, from: data))?.error.message
                ?? "Unknown error"
            throw GeminiError.apiError(statusCode: http.statusCode, message: errorMsg)
        }

        do {
            let apiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
            return try GeminiMapper.toAnalysisResult(apiResponse)
        } catch {
            if let ge = error as? GeminiError { throw ge }
            throw GeminiError.decodingError(error)
        }
    }

    // MARK: - Private

    private func buildURLRequest(
        for report:    DailyReport,
        apiKey:        String,
        systemPrompt:  String,
        hydrationUnit: HydrationUnit
    ) throws -> URLRequest {
        let urlString = "\(API.baseURL)/\(model.id):\(API.action)?key=\(apiKey)"
        guard let url = URL(string: urlString) else { throw GeminiError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GeminiRequest(
            systemInstruction: GeminiSystemContent(
                parts: [GeminiTextPart(text: systemPrompt)]
            ),
            contents: [
                GeminiUserContent(
                    role:  "user",
                    parts: buildParts(for: report, hydrationUnit: hydrationUnit)
                )
            ],
            generationConfig: GeminiGenerationConfig(maxOutputTokens: API.maxOutputTokens)
        )

        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    /// Images first (meal photos), then the formatted report text.
    private func buildParts(for report: DailyReport, hydrationUnit: HydrationUnit) -> [GeminiPart] {
        var parts: [GeminiPart] = []

        for log in report.mealLogs {
            if let data = log.photoData {
                parts.append(.image(mimeType: "image/jpeg", base64Data: data.base64EncodedString()))
            }
        }

        parts.append(.text(ReportFormatter.format(report, hydrationUnit: hydrationUnit)))
        return parts
    }
}
