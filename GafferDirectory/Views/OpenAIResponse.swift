import Foundation
struct OpenAIResponse: Decodable {
    struct Choice: Decodable {
        let message: OpenAIMessage
    }

    struct OpenAIMessage: Decodable {
        let content: String
    }

    let id: String
    let object: String
    let created: Int
    let model: String
    let usage: OpenAIUsage
    let choices: [Choice]
}

struct OpenAIUsage: Decodable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}
