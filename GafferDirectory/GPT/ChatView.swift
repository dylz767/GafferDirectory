import SwiftUI
import Alamofire

struct ChatView: View {
    @ObservedObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages, id: \.id) { message in
                        messageView(message: message)
                    }
                }
            }
            HStack {
                TextField("Enter a message", text: $viewModel.currentInput)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Text("Send")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .padding(.bottom, 8)
    }
    
    func messageView(message: Message) -> some View {
        HStack{
            if message.role == .user { Spacer() }
            Text(message.content)
                .padding()
                .foregroundColor(message.role == .user ? .black : .white)
                .background(message.role == .user ? Color.gray.opacity(0.2) : Color.blue)
                .cornerRadius(12)
            if message.role == .assistant { Spacer() }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
