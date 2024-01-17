//
//  ContentView.swift
//  GafferDirectory
//
//  Created by Dylon Angol on 14/01/2024.
//

import SwiftUI
import Alamofire

struct ChatView: View {

    @ObservedObject var viewModel = ViewModel()
    
    let openAIService = OpenAIService()
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages.filter({$0.role != .system}), id: \.id) { message in
                                    messageView(message: message)
                    }
                }
            }
            HStack {
                TextField("enter a message", text: $viewModel.currentInput)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                Button{
                    viewModel.sendMessage()
                }
            label: {
                Text("Send")
                    
                }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(12)
            }
        }
        .padding(.bottom, 8)
    }
    func messageView(message: Message) -> some View {
        HStack{
            if message.role == .user { Spacer()}
            Text(message.content)
            if message.role == .assistant { Spacer()}
        }
        
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
