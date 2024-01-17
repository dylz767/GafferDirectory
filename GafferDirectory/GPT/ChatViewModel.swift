//
//  ChatViewModel.swift
//  CrewBot
//
//  Created by Dylon Angol on 15/01/2024.
//
import Alamofire
import Foundation


extension ChatView {
    class ViewModel: ObservableObject {
        @Published var messages: [Message] = []
        @Published var currentInput: String = ""
        private let openAIService = OpenAIService()
        func sendMessage()
        {
            let newMessage = Message(id: UUID(), role: .user, content: currentInput, createdAt: Date())
            messages.append(newMessage)
            currentInput = ""
            
            Task{
                let response = await openAIService.sendMessage(messages: messages)
                guard let receivedOpenAIMessage = response?.choices.first?.message else {
                    print("no received message")
                    return
                }
                let receivedMessage = Message(id: UUID(), role: receivedOpenAIMessage.role, content: receivedOpenAIMessage.content, createdAt: Date())
                await MainActor.run {
                    messages.append(receivedMessage)
                }
            }
        }
    }
}
struct Message: Decodable
{
    let id: UUID
    let role: SenderRole
    let content: String
    let createdAt: Date
    
}
