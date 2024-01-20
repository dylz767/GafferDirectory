import Foundation
import Alamofire

extension OpenAIService {
    
    func sendCustomQuery(query: String, userProfession: String?) async -> OpenAIChatResponse? {
        var contextualQuery = query
        if let profession = userProfession {
            // Add the profession as context to the query
            contextualQuery = "Profession: \(profession)\nQuery: \(query)"
        }
        let openAIMessages = [OpenAIChatMessage(role: .user, content: contextualQuery)]
        let body = OpenAIChatBody(model: "gpt-3.5-turbo", messages: openAIMessages)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.openAIApiKey)",
            "Content-Type": "application/json"
        ]
        
        do {
            let response = try await AF.request(endpointURL, method: .post, parameters: body, encoder: JSONParameterEncoder.default, headers: headers)
                .serializingDecodable(OpenAIChatResponse.self)
                .value
            return response
        } catch {
            print("Error while sending custom query: \(error.localizedDescription)")
            return nil
        }
    }
}
class OpenAIService {
    private let endpointURL = "https://api.openai.com/v1/chat/completions"
    
    func sendMessage(messages: [Message]) async -> OpenAIChatResponse? {
        let openAIMessages = messages.map({OpenAIChatMessage(role: $0.role , content: $0.content)})
        let body = OpenAIChatBody(model: "gpt-3.5-turbo-1106", messages: openAIMessages)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.openAIApiKey)"
            ]
        return try? await AF.request(endpointURL, method: .post, parameters: body, encoder: .json, headers: headers).serializingDecodable(OpenAIChatResponse.self).value
    }
}
struct OpenAIChatBody: Encodable {
    
    let model: String
    let messages: [OpenAIChatMessage]
    
}
struct OpenAIChatMessage: Codable {
    
    let role: SenderRole
    let content: String
    
}
enum SenderRole: String, Codable{
    case system
    case user
    case assistant
}
struct OpenAIChatResponse: Decodable {
    let choices: [OpenAIChatChoice]
}
struct OpenAIChatChoice: Decodable {
    let message: OpenAIChatMessage
}

struct AssistantRequestBody: Encodable {
    let input: String
    let session: String?
}

struct AssistantResponse: Decodable {
    // Update or remove fields according to the actual API response
    let id: String? // Making it optional in case it's not in the response
    let object: String?
    let created: Int?
    let session: String?
    let choices: [Choice]?

    struct Choice: Decodable {
        let message: Message?
    }

    struct Message: Decodable {
        let role: String?
        let content: String?
    }
}

