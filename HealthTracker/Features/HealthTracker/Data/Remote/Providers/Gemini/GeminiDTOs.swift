import Foundation

// MARK: - Request

struct GeminiRequest: Encodable {
    let systemInstruction: GeminiSystemContent
    let contents:          [GeminiUserContent]
    let generationConfig:  GeminiGenerationConfig

    enum CodingKeys: String, CodingKey {
        case systemInstruction = "system_instruction"
        case contents
        case generationConfig
    }
}

/// System instruction — no role field.
struct GeminiSystemContent: Encodable {
    let parts: [GeminiTextPart]
}

/// User/model turn — includes role.
struct GeminiUserContent: Encodable {
    let role:  String
    let parts: [GeminiPart]
}

struct GeminiTextPart: Encodable {
    let text: String
}

/// A content part: plain text or an inline image.
enum GeminiPart: Encodable {
    case text(String)
    case image(mimeType: String, base64Data: String)

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode(text, forKey: .text)

        case .image(let mimeType, let base64Data):
            var inline = container.nestedContainer(keyedBy: InlineKeys.self, forKey: .inlineData)
            try inline.encode(mimeType,    forKey: .mimeType)
            try inline.encode(base64Data,  forKey: .data)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case text
        case inlineData = "inline_data"
    }
    private enum InlineKeys: String, CodingKey {
        case mimeType = "mime_type"
        case data
    }
}

struct GeminiGenerationConfig: Encodable {
    let maxOutputTokens: Int
}

// MARK: - Response

struct GeminiResponse: Decodable {
    let candidates:    [GeminiCandidate]
    let usageMetadata: GeminiUsageMetadata?
}

struct GeminiCandidate: Decodable {
    let content:      GeminiResponseContent
    let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case content
        case finishReason
    }
}

struct GeminiResponseContent: Decodable {
    let parts: [GeminiResponsePart]
    let role:  String
}

struct GeminiResponsePart: Decodable {
    let text: String?
}

struct GeminiUsageMetadata: Decodable {
    let promptTokenCount:     Int?
    let candidatesTokenCount: Int?
}

// MARK: - Error response

struct GeminiErrorResponse: Decodable {
    let error: GeminiErrorDetail
}

struct GeminiErrorDetail: Decodable {
    let code:    Int
    let message: String
    let status:  String
}
