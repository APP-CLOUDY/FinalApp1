import SwiftUI

// MARK: - 1. Core Models and State Management

enum AppState: Equatable {
    case chatWelcome
    case missionCluster
    case missionDetail(Mission)
    
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        switch (lhs, rhs) {
        case (.chatWelcome, .chatWelcome): return true
        case (.missionCluster, .missionCluster): return true
        case (.missionDetail(let l), .missionDetail(let r)): return l == r
        default: return false
        }
    }
}

// MARK: - Theme Configuration
extension Color {
    // Background Gradient
    static let bgGradientStart = Color(red: 15/255, green: 18/255, blue: 24/255)
    static let bgGradientEnd = Color(red: 36/255, green: 55/255, blue: 99/255)
    
    // UI Colors
    static let chatLightBg = Color(red: 0.82, green: 0.84, blue: 0.88)
    static let missionCardBg = Color(red: 0.22, green: 0.24, blue: 0.32) // Specific Dark Card
    static let darkButtonNavy = Color(red: 0.11, green: 0.20, blue: 0.35)
    static let buttonStroke = Color(red: 0.3, green: 0.4, blue: 0.6)
    static let accentPurple = Color(red: 0.45, green: 0.35, blue: 0.95)
    
    // Bubble Neon Colors
    static let neonPink = Color(red: 1.0, green: 0.6, blue: 0.7)
    static let neonBlue = Color(red: 0.4, green: 0.65, blue: 1.0)
    static let neonGreen = Color(red: 0.4, green: 0.8, blue: 0.6)
}

// MARK: - Data Model
struct Mission: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let time: String
    let color: Color
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - 2. Main Flow Controller View

struct CloudyFlowView: View {
    @State private var currentState: AppState = .chatWelcome
    @State private var textInput: String = ""
    @State private var completedMissionIDs: Set<UUID> = []
    
    // Tracks which bubble is animating away
    @State private var dissolvingMissionID: UUID? = nil
    
    let missions: [Mission] = [
        Mission(title: "News", time: "6:00 pm", color: .neonPink, size: 90, x: -100, y: -40),
        Mission(title: "Home\nwork", time: "6:30 pm", color: .neonBlue, size: 85, x: -60, y: 85),
        Mission(title: "Play", time: "6:30 pm", color: .neonPink, size: 90, x: -100, y: 210),
        Mission(title: "Brush", time: "5:30 am", color: .neonGreen, size: 80, x: 20, y: 20),
        Mission(title: "Do Dishes", time: "10:30 pm", color: .neonGreen, size: 90, x: 10, y: 220),
        Mission(title: "Mop", time: "6:30 pm", color: .neonBlue, size: 65, x: 90, y: 270),
        Mission(title: "Clean", time: "6:30 pm", color: .neonBlue, size: 65, x: 80, y: -50),
        Mission(title: "Jog", time: "6:30 pm", color: .neonBlue, size: 65, x: 100, y: 55),
        Mission(title: "Shop", time: "7:30 am", color: .neonGreen, size: 75, x: 140, y: -10),
        Mission(title: "Water Your Plants", time: "8:30 pm", color: .neonPink, size: 130, x: 120, y: 160)
    ]
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [.bgGradientStart, .bgGradientEnd]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // CORRECTED HEADER
                header
                
                Group {
                    switch currentState {
                    case .chatWelcome:
                        WelcomeView(currentState: $currentState)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    case .missionCluster:
                        MissionClusterView(
                            currentState: $currentState,
                            missions: missions,
                            completedMissionIDs: $completedMissionIDs,
                            dissolvingMissionID: $dissolvingMissionID
                        )
                        .transition(.opacity)
                    case .missionDetail(let mission):
                        MissionDetailView(
                            currentState: $currentState,
                            mission: mission,
                            dissolvingMissionID: $dissolvingMissionID
                        )
                        .transition(.slide)
                    }
                }
                
                Spacer()
                inputBar
            }
            // Dismiss keyboard logic
            .simultaneousGesture(DragGesture().onChanged({ _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }))
        }
    }
    
    // MARK: - Header (Navigation Style)
    var header: some View {
        VStack(spacing: 0) {
            ZStack {
                // 1. Title Centered
                Text("Cloudyy")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                // 2. Buttons Pinned to Edges
                HStack {
                    // Back Button
                    Button(action: {
                        withAnimation {
                            if case .missionDetail = currentState {
                                currentState = .missionCluster
                            } else if currentState == .missionCluster {
                                currentState = .chatWelcome
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(currentState == .chatWelcome ? .clear : .blue)
                    }
                    .disabled(currentState == .chatWelcome)
                    
                    Spacer()
                    
                    // Profile Icon
                    Button(action: {}) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(height: 44) // Standard iOS Nav Bar Height
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            
            // 3. Separator Line
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 0.5)
        }
        .padding(.top, 10)
    }
    
    // MARK: - Input Bar
    var inputBar: some View {
        HStack(spacing: 15) {
            HStack {
                TextField("", text: $textInput)
                    .placeholder(when: textInput.isEmpty) {
                        Text("Ask me !").foregroundColor(.gray)
                    }
                    .foregroundColor(.black)
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(25)
            
            Button(action: {}) {
                ZStack {
                    Circle()
                        .fill(Color.accentPurple)
                        .frame(width: 50, height: 50)
                    Image(systemName: "paperplane")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .offset(x: -2, y: 2)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}

// MARK: - 3. Screens

struct WelcomeView: View {
    @Binding var currentState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Image("cloudyy_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .shadow(color: .white.opacity(0.15), radius: 15)
                    .padding(.top, 40)
                
                ChatBubbleContainer {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                            .font(.system(size: 18))
                        Text("Hi, Lets Complete all Mission")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.black.opacity(0.7))
                    }
                }
                
                ChatBubbleContainer {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.purple)
                                .font(.system(size: 18))
                            Text("I got you some missions for you today.\nWant to see them ??")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.black.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(4)
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.spring()) { currentState = .missionCluster }
                            }) {
                                Text("Yes, show me!")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.darkButtonNavy)
                                    .cornerRadius(14)
                            }
                            
                            Button(action: {}) {
                                Text("Maybe later")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.darkButtonNavy.opacity(0.6))
                                    .cornerRadius(14)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
}

struct MissionClusterView: View {
    @Binding var currentState: AppState
    let missions: [Mission]
    @Binding var completedMissionIDs: Set<UUID>
    @Binding var dissolvingMissionID: UUID?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ChatBubbleContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "sparkles").foregroundColor(.purple)
                            Text("I got you some missions for you today.\nWant to see them ??")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.black.opacity(0.7))
                        }
                        HStack {
                             Text("Yes, show me!").font(.caption.bold()).foregroundColor(.white).padding(10).background(Color.darkButtonNavy).cornerRadius(10)
                             Text("Maybe later").font(.caption).foregroundColor(.white.opacity(0.7)).padding(10).background(Color.darkButtonNavy.opacity(0.5)).cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Text("Which mission should we do next")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.top, 35)
                
                ZStack {
                    Image("cloudBasket")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170)
                        .offset(x: -80, y: -120)
                    
                    ForEach(missions) { mission in
                        if !completedMissionIDs.contains(mission.id) {
                            if mission.id == dissolvingMissionID {
                                DissolvingBubble(mission: mission) {
                                    completedMissionIDs.insert(mission.id)
                                    dissolvingMissionID = nil
                                }
                                .offset(x: mission.x, y: mission.y)
                            } else {
                                FloatingMissionItem(mission: mission)
                                    .onTapGesture {
                                        withAnimation(.easeOut) { currentState = .missionDetail(mission) }
                                    }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 450)
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - DETAIL VIEW
struct MissionDetailView: View {
    @Binding var currentState: AppState
    let mission: Mission
    @Binding var dissolvingMissionID: UUID?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                
                ChatBubbleContainer {
                    HStack {
                        Image(systemName: "sparkles").foregroundColor(.purple)
                        Text("Great Choice , Lets do it !")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.black.opacity(0.7))
                    }
                }
                .padding(.horizontal, 20)
                
                // 1. "Mission" as a Header (Topic)
                Text("Mission")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.bottom, -15)
                
                // 2. The Card (Content Only)
                HStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(mission.color)
                        .frame(width: 6)
                        .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(mission.title.replacingOccurrences(of: "\n", with: " "))
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(mission.time)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.leading, 12)
                    .padding(.vertical, 12)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .background(Color.missionCardBg) // Specific dark grey-blue
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // 3. Cloud & Speech Bubble with Tail
                ZStack(alignment: .bottomTrailing) {
                    Image("cloudUmbrella")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170)
                        .padding(.trailing, 20)
                    
                    ZStack(alignment: .bottomTrailing) {
                        Text("Let me know, When\nyou are done!")
                            .font(.system(size: 14, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 18)
                            .background(Color.white)
                            .cornerRadius(20)
                        
                        Image(systemName: "arrowtriangle.down.fill")
                            .resizable()
                            .frame(width: 18, height: 12)
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(-30))
                            .offset(x: -15, y: 8)
                    }
                    .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
                    .offset(x: -95, y: -100)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 50)
                .padding(.trailing, 20)
                
                HStack(spacing: 16) {
                    Button(action: handleDone) {
                        Text("Done!")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.darkButtonNavy)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.buttonStroke, lineWidth: 1))
                            .cornerRadius(16)
                    }
                    
                    Button(action: { withAnimation { currentState = .missionCluster } }) {
                        Text("Back")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.darkButtonNavy)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.buttonStroke, lineWidth: 1))
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .padding(.top, 20)
        }
    }
    
    func handleDone() {
        dissolvingMissionID = mission.id
        withAnimation {
            currentState = .missionCluster
        }
    }
}

// MARK: - 4. Effects & Helpers

// Transparent Glass Bubble
struct GlassyBubble: View {
    let mission: Mission
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.3)) // Dark tint, transparent
            Circle()
                .stroke(mission.color.opacity(0.6), lineWidth: 1.0)
            VStack(spacing: 4) {
                Text(mission.title)
                    .font(.system(size: mission.size > 100 ? 15 : 12, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(mission.color) // Neon text
                    .padding(.horizontal, 4)
                Text(mission.time)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(width: mission.size, height: mission.size)
        .shadow(color: mission.color.opacity(0.2), radius: 8, x: 0, y: 0)
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

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct CloudyFlowView_Previews: PreviewProvider {
    static var previews: some View {
        CloudyFlowView()
    }
}

