import SwiftUI

struct CloudyInputBar: View {
    @Binding var text: String
    let isThinking: Bool
    let onSend: () -> Void
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            HStack {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text("Ask me about tasks!").foregroundColor(.gray)
                    }
                    .foregroundColor(.black)
                    .focused($isInputFocused)
                    .onSubmit {
                        onSend()
                        isInputFocused = false
                    }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(25)
            
            Button(action: {
                onSend()
                isInputFocused = false
            }) {
                ZStack {
                    Circle()
                        .fill(text.isEmpty ? Color.gray.opacity(0.5) : Color.accentPurple)
                        .frame(width: 50, height: 50)
                    
                    if isThinking {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "paperplane")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .offset(x: -2, y: 2)
                    }
                }
            }
            .disabled(text.isEmpty || isThinking)
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}
