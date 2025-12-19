import SwiftUI

// MARK: - Chat Components
struct ChatBubbleContainer<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        HStack { content; Spacer() }
            .padding(18)
            .background(Color.chatLightBg)
            .cornerRadius(24)
    }
}

struct ChatBubbleRow: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if !message.isUser {
                Image("cloudyy_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .background(Circle().fill(Color.white.opacity(0.2)))
            }
            
            Text(message.text)
                .font(.system(size: 16))
                .foregroundColor(message.isUser ? .white : .black.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    message.isUser
                    ? Color.accentPurple
                    : Color.chatLightBg
                )
                .cornerRadius(18, corners: message.isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
    }
}

struct AIChatScrollView: View {
    let messages: [ChatMessage]
    let isThinking: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(messages) { message in
                        ChatBubbleRow(message: message)
                            .id(message.id)
                    }
                    
                    if isThinking {
                        HStack {
                            Text("Cloudyy is thinking...")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .italic()
                            Spacer()
                        }
                        .padding(.leading, 20)
                    }
                    
                    Color.clear.frame(height: 60)
                }
                .padding(.top, 20)
            }
            .onChange(of: messages.count) { _ in
                if let lastId = messages.last?.id {
                    withAnimation {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
    }
}

// MARK: - Bubble Effects
struct GlassyBubble: View {
    let mission: Mission
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.3))
            Circle()
                .stroke(mission.color.opacity(0.6), lineWidth: 1.0)
            VStack(spacing: 4) {
                Text(mission.title)
                    .font(.system(size: mission.size > 100 ? 15 : 12, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(mission.color)
                    .padding(.horizontal, 4)
                
                if !mission.time.isEmpty {
                    Text(mission.time)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .frame(width: mission.size, height: mission.size)
        .shadow(color: mission.color.opacity(0.2), radius: 8, x: 0, y: 0)
    }
}

struct FloatingMissionItem: View {
    let mission: Mission
    @State private var xOffset: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        GlassyBubble(mission: mission)
            .offset(x: mission.x + xOffset, y: mission.y + yOffset)
            .onAppear {
                withAnimation(.easeInOut(duration: Double.random(in: 3...6)).repeatForever(autoreverses: true)) {
                    xOffset = CGFloat.random(in: -10...10)
                }
                withAnimation(.easeInOut(duration: Double.random(in: 2...5)).repeatForever(autoreverses: true)) {
                    yOffset = CGFloat.random(in: -15...15)
                }
            }
    }
}

struct DissolvingBubble: View {
    let mission: Mission
    var onComplete: () -> Void
    @State private var startAnim = false
    
    var body: some View {
        GlassyBubble(mission: mission)
            .offset(y: startAnim ? -150 : 0)
            .opacity(startAnim ? 0 : 1)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) { startAnim = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { onComplete() }
            }
    }
}
