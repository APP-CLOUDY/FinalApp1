import SwiftUI

struct CloudyInputBar: View {
    @Binding var text: String
    let isThinking: Bool
    let onSend: () -> Void
    let onDelete: () -> Void
    let onReport: () -> Void
    
    @FocusState private var isInputFocused: Bool
    @State private var showDeleteDialog = false
    
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
                    .onLongPressGesture {
                        showDeleteDialog = true
                    }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(25)
            .confirmationDialog("Options", isPresented: $showDeleteDialog) {
                Button("Delete Chat", role: .destructive) {
                    onDelete()
                }
                Button("Report AI Response") {
                    onReport()
                }
                Button("Cancel", role: .cancel) { }
            }
            
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
