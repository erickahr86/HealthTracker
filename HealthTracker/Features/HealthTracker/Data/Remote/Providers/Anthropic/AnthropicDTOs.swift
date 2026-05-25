import Foundation

// MARK: - Request

struct AnthropicRequest: Encodable {
    let model: String
    let maxTokens: Int
    let system: String
    let messages: [AnthropicMessage]

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case system
        case messages
    }
}

struct AnthropicMessage: Encodable {
    let role: String
    let content: [AnthropicContentBlock]
}

// MARK: - Content blocks (text or image)

enum AnthropicContentBlock: Encodable {
    case text(String)
    case image(mediaType: String, base64Data: String)

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .text)

        case .image(let mediaType, let base64Data):
            try container.encode("image", forKey: .type)
            var source = container.nestedContainer(keyedBy: SourceKeys.self, forKey: .source)
            try source.encode("base64",    forKey: .type)
            try source.encode(mediaType,   forKey: .mediaType)
            try source.encode(base64Data,  forKey: .data)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type, text, source
    }
    private enum SourceKeys: String, CodingKey {
        case type
        case mediaType = "media_type"
        case data
    }
}

// MARK: - Response

struct AnthropicResponse: Decodable {
    let id: String
    let content: [AnthropicResponseContent]
    let model: String
    let stopReason: String?
    let usage: AnthropicUsageDTO

    enum CodingKeys: String, CodingKey {
        case id, content, model, usage
        case stopReason = "stop_reason"
    }
}

struct AnthropicResponseContent: Decodable {
    let type: String
    let text: String?
}

struct AnthropicUsageDTO: Decodable {
    let inputTokens: Int
    let outputTokens: Int

    enum CodingKeys: String, CodingKey {
        case inputTokens  = "input_tokens"
        case outputTokens = "output_tokens"
    }
}

// MARK: - Error response

struct AnthropicErrorResponse: Decodable {
    let type: String
    let error: AnthropicErrorDetail
}

struct AnthropicErrorDetail: Decodable {
    let type: String
    let message: String
}
