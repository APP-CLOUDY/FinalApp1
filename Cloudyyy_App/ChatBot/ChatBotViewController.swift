//import SwiftUI
//import UIKit
//
//// MARK: - 0. Notification Name Extension
//extension Notification.Name {
//    static let taskDidComplete = Notification.Name("taskDidComplete")
//}
//
//// MARK: - 1. Core Models and State Management
//
//enum AppState: Equatable {
//    case chatWelcome
//    case missionCluster
//    case missionDetail(Mission)
//    
//    static func == (lhs: AppState, rhs: AppState) -> Bool {
//        switch (lhs, rhs) {
//        case (.chatWelcome, .chatWelcome): return true
//        case (.missionCluster, .missionCluster): return true
//        case (.missionDetail(let l), .missionDetail(let r)): return l == r
//        default: return false
//        }
//    }
//}
//
//// MARK: - AI Models
//struct ChatMessage: Identifiable, Equatable {
//    let id = UUID()
//    let text: String
//    let isUser: Bool // true = Child, false = AI
//    let timestamp = Date()
//}
//
//// MARK: - Theme Configuration
//extension Color {
//    static let bgGradientStart = Color(red: 15/255, green: 18/255, blue: 24/255)
//    static let bgGradientEnd = Color(red: 36/255, green: 55/255, blue: 99/255)
//    static let chatLightBg = Color(red: 0.82, green: 0.84, blue: 0.88)
//    static let missionCardBg = Color(red: 0.22, green: 0.24, blue: 0.32)
//    static let darkButtonNavy = Color(red: 0.11, green: 0.20, blue: 0.35)
//    static let buttonStroke = Color(red: 0.3, green: 0.4, blue: 0.6)
//    static let accentPurple = Color(red: 0.45, green: 0.35, blue: 0.95)
//    
//    // Bubble Neon Colors
//    static let neonPink = Color(red: 1.0, green: 0.6, blue: 0.7)
//    static let neonBlue = Color(red: 0.4, green: 0.65, blue: 1.0)
//    static let neonGreen = Color(red: 0.4, green: 0.8, blue: 0.6)
//    static let neonYellow = Color(red: 1.0, green: 0.9, blue: 0.4)
//}
//
//// MARK: - Data Model
//struct Mission: Identifiable, Equatable {
//    let id: UUID // Maps to Backend ID
//    let title: String
//    let time: String
//    
//    // Logic: Controls if camera is needed
//    let requiresPhoto: Bool
//    
//    // UI Properties (Randomized)
//    let color: Color
//    let size: CGFloat
//    let x: CGFloat
//    let y: CGFloat
//    
//    static func == (lhs: Mission, rhs: Mission) -> Bool {
//        return lhs.id == rhs.id
//    }
//}
//
//import Foundation
//
//// MARK: - Cloudyy Gemini AI Service (FINAL & DEBUGGABLE)
//import Foundation
//
////actor CloudyAIService {
////
////    static let shared = CloudyAIService()
////
////    // 🔑 REPLACE WITH A NEW KEY LATER (this one is compromised)
////    private let apiKey = "AIzaSyCqQpua3z7VtGC4UtEDsId2NfdYRehVH2c"
////
////    // ✅ ONLY STABLE PUBLIC MODEL
////    private let model = "gemini-pro"
////
////    func sendMessage(
////        userQuery: String,
////        missions: [Mission],
////        rewardsBalance: Int
////    ) async -> String {
////
////        let cleanKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
////
////        let endpoint =
////        "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(cleanKey)"
////
////        guard let url = URL(string: endpoint) else {
////            print("❌ Invalid URL")
////            return fallbackMessage
////        }
////
////        // --- Prompt ---
////        let missionContext = missions.map {
////            "- \($0.title) | Time: \($0.time)"
////        }.joined(separator: "\n")
////
////        let prompt = """
////        You are Cloudyy ☁️, a friendly assistant for kids.
////
////        Rules:
////        - Talk only about tasks and rewards
////        - Max 2 short sentences
////        - Use emojis ☁️✨
////
////        Tasks:
////        \(missionContext.isEmpty ? "No tasks yet." : missionContext)
////
////        Wallet: \(rewardsBalance) coins
////
////        User: \(userQuery)
////        """
////
////        let body: [String: Any] = [
////            "contents": [
////                [
////                    "parts": [
////                        ["text": prompt]
////                    ]
////                ]
////            ]
////        ]
////
////        var request = URLRequest(url: url)
////        request.httpMethod = "POST"
////        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
////        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
////
////        do {
////            let (data, response) = try await URLSession.shared.data(for: request)
////
////            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
////                print("❌ GEMINI ERROR:", http.statusCode)
////                print(String(data: data, encoding: .utf8) ?? "")
////                return fallbackMessage
////            }
////
////            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
////            let text =
////            (((json?["candidates"] as? [[String: Any]])?.first?["content"]
////              as? [String: Any])?["parts"] as? [[String: Any]])?
////                .first?["text"] as? String
////
////            return text?.trimmingCharacters(in: .whitespacesAndNewlines)
////                ?? fallbackMessage
////
////        } catch {
////            print("❌ NETWORK ERROR:", error)
////            return fallbackMessage
////        }
////    }
////
////    private var fallbackMessage: String {
////        "My cloud signal is weak… try again later! ☁️"
////    }
////}
////
////
//
//// MARK: - 2. Main Flow Controller View
//
//struct CloudyFlowView: View {
//    @State private var currentState: AppState = .chatWelcome
//    @State private var textInput: String = ""
//    @State private var completedMissionIDs: Set<UUID> = []
//    
//    // Tracks which bubble is animating away
//    @State private var dissolvingMissionID: UUID? = nil
//    
//    // Backend Data
//    @State private var missions: [Mission] = []
//    @State private var isLoading: Bool = false
//    
//    // MARK: - AI Chat State
//    @State private var chatHistory: [ChatMessage] = []
//    @State private var isAIThinking: Bool = false
//    @FocusState private var isInputFocused: Bool
//    
//    var body: some View {
//        ZStack {
//            // Background Gradient
//            LinearGradient(
//                gradient: Gradient(colors: [.bgGradientStart, .bgGradientEnd]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                header
//                
//                // MAIN CONTENT AREA (Switches between Chat and App)
//                ZStack {
//                    if chatHistory.isEmpty {
//                        // Standard App Flow
//                        Group {
//                            switch currentState {
//                            case .chatWelcome:
//                                WelcomeView(currentState: $currentState)
//                                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
//                            case .missionCluster:
//                                MissionClusterView(
//                                    currentState: $currentState,
//                                    missions: missions,
//                                    completedMissionIDs: $completedMissionIDs,
//                                    dissolvingMissionID: $dissolvingMissionID,
//                                    isLoading: isLoading
//                                )
//                                .transition(.opacity)
//                            case .missionDetail(let mission):
//                                MissionDetailView(
//                                    currentState: $currentState,
//                                    mission: mission,
//                                    completedMissionIDs: $completedMissionIDs,
//                                    dissolvingMissionID: $dissolvingMissionID
//                                )
//                                .transition(.slide)
//                            }
//                        }
//                    } else {
//                        // AI Chat Flow
//                        AIChatScrollView(messages: chatHistory, isThinking: isAIThinking)
//                            .transition(.move(edge: .bottom))
//                    }
//                }
//                .animation(.spring(), value: chatHistory.isEmpty)
//                .animation(.spring(), value: currentState)
//                
//                Spacer()
//                inputBar
//            }
//            .simultaneousGesture(DragGesture().onChanged({ _ in
//                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//            }))
//        }
//        .task {
//            await loadBackendMissions()
//        }
//    }
//    
//    // MARK: - Data Fetching (REAL BACKEND LOGIC)
//    private func loadBackendMissions() async {
//        guard missions.isEmpty else { return }
//        
//        isLoading = true
//        defer { isLoading = false }
//    
//        
//        do {
//            // ✅ RESTORED: Calling your ChildHomeService
//            let tasks = try await ChildHomeService.shared.fetchSchedule(date: Date())
//            
//            // Filter: Only show tasks NOT approved and NOT pending
//            let actionableTasks = tasks.filter {
//                $0.submission_status != "approved" && $0.submission_status != "pending"
//            }
//            
//            self.missions = actionableTasks.enumerated().map { index, task in
//                let randomSize = CGFloat.random(in: 75...110)
//                let colors: [Color] = [.neonPink, .neonBlue, .neonGreen, .neonYellow]
//                let randomColor = colors.randomElement() ?? .neonBlue
//                
//                let randomX = CGFloat.random(in: -140...140)
//                let baseY = CGFloat(index * 35) - 50
//                let jitterY = CGFloat.random(in: -30...30)
//                
//                return Mission(
//                    id: task.id,
//                    title: task.title,
//                    time: task.frequency,
//                    // Logic: Use backend flag
//                    requiresPhoto: task.approval_required ?? false,
//                    color: randomColor,
//                    size: randomSize,
//                    x: randomX,
//                    y: baseY + jitterY
//                )
//            }
//        } catch {
//            print("Failed to load missions: \(error)")
//        }
//    }
//    
//    // MARK: - Header
//    var header: some View {
//        VStack(spacing: 0) {
//            ZStack {
//                Text("Cloudyy")
//                    .font(.system(size: 17, weight: .semibold))
//                    .foregroundColor(.white)
//                
//                HStack {
//                    // Back Button Logic
//                    Button(action: {
//                        withAnimation {
//                            if !chatHistory.isEmpty {
//                                chatHistory.removeAll()
//                                isInputFocused = false
//                            } else if case .missionDetail = currentState {
//                                currentState = .missionCluster
//                            } else if currentState == .missionCluster {
//                                currentState = .chatWelcome
//                            }
//                        }
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 22, weight: .semibold))
//                            .foregroundColor((currentState == .chatWelcome && chatHistory.isEmpty) ? .clear : .white)
//                    }
//                    .disabled(currentState == .chatWelcome && chatHistory.isEmpty)
//                    
//                    Spacer()
//                    
//                    Button(action: {}) {
//                        Image(systemName: "person.circle")
//                            .font(.system(size: 26))
//                            .foregroundColor(.white)
//                    }
//                }
//            }
//            .frame(height: 44)
//            .padding(.horizontal, 16)
//            .padding(.bottom, 8)
//            
//            Rectangle()
//                .fill(Color.white.opacity(0.15))
//                .frame(height: 0.5)
//        }
//        .padding(.top, -50) // ✅ INCREASED PADDING FOR NOTCH
//    }
//    
//    // MARK: - Input Bar
//    var inputBar: some View {
//        HStack(spacing: 15) {
//            HStack {
//                TextField("", text: $textInput)
//                    .placeholder(when: textInput.isEmpty) {
//                        Text("Ask me about tasks!").foregroundColor(.gray)
//                    }
//                    .foregroundColor(.black)
//                    .focused($isInputFocused)
//                    .onSubmit {
//                        performSendMessage()
//                    }
//            }
//            .padding(14)
//            .background(Color.white)
//            .cornerRadius(25)
//            
//            Button(action: performSendMessage) {
//                ZStack {
//                    Circle()
//                        .fill(textInput.isEmpty ? Color.gray.opacity(0.5) : Color.accentPurple)
//                        .frame(width: 50, height: 50)
//                    
//                    if isAIThinking {
//                        ProgressView().tint(.white)
//                    } else {
//                        Image(systemName: "paperplane")
//                            .font(.system(size: 22))
//                            .foregroundColor(.white)
//                            .offset(x: -2, y: 2)
//                    }
//                }
//            }
//            .disabled(textInput.isEmpty || isAIThinking)
//        }
//        .padding(.horizontal)
//        .padding(.top, 10)
//        .padding(.bottom, 20)
//    }
//    
//    // MARK: - AI Action Logic
//    func performSendMessage() {
//        guard !textInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
//        
//        let userText = textInput
//        textInput = ""
//        isInputFocused = false
//        
//        withAnimation {
//            chatHistory.append(ChatMessage(text: userText, isUser: true))
//        }
//        
//        isAIThinking = true
//        
//        Task {
//            do {
//                // Fetch simulated rewards (or replace with ChildHomeService.shared.getCoins() if available)
//                let currentRewards = 150
//                
//                let response = await OllamaAIService.shared.sendMessage(
//                    userQuery: userText,
//                    missions: missions,
//                    rewardsBalance: currentRewards
//                )
//
//                
//                await MainActor.run {
//                    withAnimation {
//                        chatHistory.append(ChatMessage(text: response, isUser: false))
//                        isAIThinking = false
//                    }
//                }
//            } catch {
//                await MainActor.run {
//                    chatHistory.append(ChatMessage(text: "My cloud signal is weak... try again later!", isUser: false))
//                    isAIThinking = false
//                }
//            }
//        }
//    }
//}
//
//// MARK: - 3. Screens
//
//struct WelcomeView: View {
//    @Binding var currentState: AppState
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 25) {
//                // ✅ RESTORED ASSET IMAGE
//                Image("cloudyy_logo")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 150)
//                    .shadow(color: .white.opacity(0.15), radius: 15)
//                    .padding(.top, 40)
//                
//                ChatBubbleContainer {
//                    HStack(spacing: 12) {
//                        Image(systemName: "sparkles")
//                            .foregroundColor(.purple)
//                            .font(.system(size: 18))
//                        Text("Hi, Lets Complete all Mission")
//                            .font(.system(size: 16, weight: .medium))
//                            .foregroundColor(Color.black.opacity(0.7))
//                    }
//                }
//                
//                ChatBubbleContainer {
//                    VStack(alignment: .leading, spacing: 16) {
//                        HStack(alignment: .top, spacing: 12) {
//                            Image(systemName: "sparkles")
//                                .foregroundColor(.purple)
//                                .font(.system(size: 18))
//                            Text("I got you some missions for you today.\nWant to see them ??")
//                                .font(.system(size: 16, weight: .medium))
//                                .foregroundColor(Color.black.opacity(0.7))
//                                .fixedSize(horizontal: false, vertical: true)
//                                .lineSpacing(4)
//                        }
//                        
//                        HStack(spacing: 12) {
//                            Button(action: {
//                                withAnimation(.spring()) { currentState = .missionCluster }
//                            }) {
//                                Text("Yes, show me!")
//                                    .font(.system(size: 15, weight: .bold))
//                                    .foregroundColor(.white)
//                                    .padding(.vertical, 14)
//                                    .padding(.horizontal, 16)
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.darkButtonNavy)
//                                    .cornerRadius(14)
//                            }
//                            
//                            Button(action: {}) {
//                                Text("Maybe later")
//                                    .font(.system(size: 15, weight: .regular))
//                                    .foregroundColor(.white.opacity(0.8))
//                                    .padding(.vertical, 14)
//                                    .padding(.horizontal, 16)
//                                    .frame(maxWidth: .infinity)
//                                    .background(Color.darkButtonNavy.opacity(0.6))
//                                    .cornerRadius(14)
//                            }
//                        }
//                    }
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 20)
//        }
//    }
//}
//
//struct MissionClusterView: View {
//    @Binding var currentState: AppState
//    let missions: [Mission]
//    @Binding var completedMissionIDs: Set<UUID>
//    @Binding var dissolvingMissionID: UUID?
//    let isLoading: Bool
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                
//                ChatBubbleContainer {
//                    VStack(alignment: .leading, spacing: 12) {
//                        HStack(alignment: .top, spacing: 12) {
//                            Image(systemName: "sparkles").foregroundColor(.purple)
//                            Text("Here are your tasks for today!")
//                                .font(.system(size: 16, weight: .medium))
//                                .foregroundColor(Color.black.opacity(0.7))
//                        }
//                    }
//                }
//                .padding(.horizontal, 20)
//                
//                Text("Tap a bubble to start")
//                    .font(.system(size: 19, weight: .bold))
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 24)
//                    .padding(.top, 15)
//                
//                if isLoading {
//                    HStack {
//                        Spacer()
//                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(1.5)
//                        Spacer()
//                    }
//                    .padding(.top, 50)
//                } else if missions.isEmpty {
//                    Text("No missions found for today!\nRelax & Enjoy ☁️")
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(.white.opacity(0.6))
//                        .frame(maxWidth: .infinity)
//                        .padding(.top, 50)
//                } else {
//                    // Floating Bubbles Area
//                    ZStack {
//                        // ✅ RESTORED CLOUD BASKET IMAGE
//                        Image("cloudBasket")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 170)
//                            .offset(x: -80, y: -120)
//                            .opacity(0.5)
//                        
//                        ForEach(missions) { mission in
//                            if !completedMissionIDs.contains(mission.id) {
//                                if mission.id == dissolvingMissionID {
//                                    DissolvingBubble(mission: mission) {
//                                        completedMissionIDs.insert(mission.id)
//                                        dissolvingMissionID = nil
//                                    }
//                                    .offset(x: mission.x, y: mission.y)
//                                } else {
//                                    FloatingMissionItem(mission: mission)
//                                        .onTapGesture {
//                                            withAnimation(.easeOut) { currentState = .missionDetail(mission) }
//                                        }
//                                }
//                            }
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 500)
//                }
//            }
//            .padding(.top, 20)
//        }
//    }
//}
//
//struct MissionDetailView: View {
//    @Binding var currentState: AppState
//    let mission: Mission
//    @Binding var completedMissionIDs: Set<UUID>
//    @Binding var dissolvingMissionID: UUID?
//    
//    // Logic States
//    @State private var showCamera = false
//    @State private var capturedImage: UIImage?
//    @State private var isUploading = false
//    
//    var body: some View {
//        ZStack {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 25) {
//                    
//                    ChatBubbleContainer {
//                        HStack {
//                            Image(systemName: "sparkles").foregroundColor(.purple)
//                            Text(mission.requiresPhoto ? "I need a photo proof for this one!" : "Great Choice , Lets do it !")
//                                .font(.system(size: 16, weight: .medium))
//                                .foregroundColor(Color.black.opacity(0.7))
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    
//                    Text("Mission")
//                        .font(.title3.bold())
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 24)
//                        .padding(.bottom, -15)
//                    
//                    // Mission Info Card
//                    HStack(alignment: .top) {
//                        RoundedRectangle(cornerRadius: 3)
//                            .fill(mission.color)
//                            .frame(width: 6)
//                            .padding(.vertical, 8)
//                        
//                        VStack(alignment: .leading, spacing: 6) {
//                            Text(mission.title.replacingOccurrences(of: "\n", with: " "))
//                                .font(.title2.bold())
//                                .foregroundColor(.white)
//                            
//                            HStack(spacing: 6) {
//                                Image(systemName: "clock.arrow.circlepath")
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                                Text(mission.time)
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                        .padding(.leading, 12)
//                        .padding(.vertical, 12)
//                        
//                        Spacer()
//                    }
//                    .padding(.horizontal, 16)
//                    .background(Color.missionCardBg)
//                    .cornerRadius(16)
//                    .padding(.horizontal, 20)
//                    
//                    // Photo Preview
//                    if let img = capturedImage {
//                        ZStack(alignment: .topTrailing) {
//                            Image(uiImage: img)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: 180)
//                                .cornerRadius(12)
//                            
//                            Button(action: { capturedImage = nil }) {
//                                Image(systemName: "xmark.circle.fill")
//                                    .foregroundColor(.red)
//                                    .background(Circle().fill(Color.white))
//                            }
//                            .padding(6)
//                        }
//                        .padding(.horizontal, 20)
//                    }
//                    
//                    // ✅ RESTORED CLOUD UMBRELLA DECORATION
//                    ZStack(alignment: .bottomTrailing) {
//                        Image("cloudUmbrella")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 170)
//                            .padding(.trailing, 20)
//                        
//                        ZStack(alignment: .bottomTrailing) {
//                            Text("Let me know, When\nyou are done!")
//                                .font(.system(size: 14, weight: .bold))
//                                .multilineTextAlignment(.center)
//                                .padding(.vertical, 14)
//                                .padding(.horizontal, 18)
//                                .background(Color.white)
//                                .cornerRadius(20)
//                            
//                            Image(systemName: "arrowtriangle.down.fill")
//                                .resizable()
//                                .frame(width: 18, height: 12)
//                                .foregroundColor(.white)
//                                .rotationEffect(.degrees(-30))
//                                .offset(x: -15, y: 8)
//                        }
//                        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
//                        .offset(x: -95, y: -100)
//                    }
//                    .frame(maxWidth: .infinity, alignment: .trailing)
//                    .padding(.top, 50)
//                    .padding(.trailing, 20)
//                    
//                    HStack(spacing: 16) {
//                        // Done/Submit Button
//                        Button(action: handleDoneTap) {
//                            HStack {
//                                if isUploading {
//                                    ProgressView().tint(.white)
//                                    Text(" Uploading...")
//                                } else {
//                                    if mission.requiresPhoto && capturedImage == nil {
//                                        Text("Add Photo 🖼️")
//                                    } else if capturedImage != nil {
//                                        Text("Submit")
//                                    } else {
//                                        Text("Done!")
//                                    }
//                                }
//                            }
//                            .font(.headline.bold())
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 16)
//                            .background(Color.darkButtonNavy)
//                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.buttonStroke, lineWidth: 1))
//                            .cornerRadius(16)
//                        }
//                        .disabled(isUploading)
//                        
//                        Button(action: { withAnimation { currentState = .missionCluster } }) {
//                            Text("Back")
//                                .font(.headline.bold())
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 16)
//                                .background(Color.darkButtonNavy)
//                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.buttonStroke, lineWidth: 1))
//                                .cornerRadius(16)
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 30)
//                }
//                .padding(.top, 20)
//            }
//            .blur(radius: isUploading ? 2 : 0)
//        }
//        .fullScreenCover(isPresented: $showCamera) {
//            CameraView(selectedImage: $capturedImage)
//        }
//    }
//    
//    func handleDoneTap() {
//        if mission.requiresPhoto && capturedImage == nil {
//            showCamera = true
//            return
//        }
//        startSubmissionProcess()
//    }
//    
//    func startSubmissionProcess() {
//        isUploading = true
//        _Concurrency.Task {
//            do {
//                var finalPhotoUrl: String? = nil
//                
//                if let img = capturedImage, let childId = SessionManager.shared.childId {
//                    finalPhotoUrl = try await ChildHomeService.shared.uploadProof(image: img, childId: childId)
//                }
//                
//                try await ChildHomeService.shared.submitTask(taskId: mission.id, photoUrl: finalPhotoUrl)
//                
//                await navigateBackToHome()
//            } catch {
//                print("Error submitting: \(error)")
//                await navigateBackToHome()
//            }
//        }
//    }
//    
//    @MainActor
//    func navigateBackToHome() {
//        isUploading = false
//        completedMissionIDs.insert(mission.id)
//        dissolvingMissionID = mission.id
//        withAnimation {
//            currentState = .missionCluster
//        }
//        NotificationCenter.default.post(name: .taskDidComplete, object: nil)
//    }
//}
//
//// MARK: - 4. Chat UI Components
//
//struct AIChatScrollView: View {
//    let messages: [ChatMessage]
//    let isThinking: Bool
//    
//    var body: some View {
//        ScrollViewReader { proxy in
//            ScrollView {
//                VStack(spacing: 20) {
//                    ForEach(messages) { message in
//                        ChatBubbleRow(message: message)
//                            .id(message.id)
//                    }
//                    
//                    if isThinking {
//                        HStack {
//                            Text("Cloudyy is thinking...")
//                                .font(.caption)
//                                .foregroundColor(.white.opacity(0.7))
//                                .italic()
//                            Spacer()
//                        }
//                        .padding(.leading, 20)
//                    }
//                    
//                    Color.clear.frame(height: 60)
//                }
//                .padding(.top, 20)
//            }
//            .onChange(of: messages.count) { _ in
//                if let lastId = messages.last?.id {
//                    withAnimation {
//                        proxy.scrollTo(lastId, anchor: .bottom)
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct ChatBubbleRow: View {
//    let message: ChatMessage
//    
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 12) {
//            if !message.isUser {
//                // ✅ RESTORED CLOUDY LOGO
//                Image("cloudyy_logo")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 35, height: 35)
//                    .background(Circle().fill(Color.white.opacity(0.2)))
//            }
//            
//            Text(message.text)
//                .font(.system(size: 16))
//                .foregroundColor(message.isUser ? .white : .black.opacity(0.8))
//                .padding(.horizontal, 16)
//                .padding(.vertical, 12)
//                .background(
//                    message.isUser
//                    ? Color.accentPurple
//                    : Color.chatLightBg
//                )
//                .cornerRadius(18, corners: message.isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
//                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
//            
//            if !message.isUser { Spacer() }
//        }
//        .padding(.horizontal, 16)
//        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
//    }
//}
//
//// MARK: - 5. Effects & Helpers
//
//struct GlassyBubble: View {
//    let mission: Mission
//    
//    var body: some View {
//        ZStack {
//            Circle()
//                .fill(Color.black.opacity(0.3))
//            Circle()
//                .stroke(mission.color.opacity(0.6), lineWidth: 1.0)
//            VStack(spacing: 4) {
//                Text(mission.title)
//                    .font(.system(size: mission.size > 100 ? 15 : 12, weight: .semibold))
//                    .multilineTextAlignment(.center)
//                    .foregroundColor(mission.color)
//                    .padding(.horizontal, 4)
//                
//                if !mission.time.isEmpty {
//                    Text(mission.time)
//                        .font(.system(size: 10, weight: .regular))
//                        .foregroundColor(.white.opacity(0.6))
//                }
//            }
//        }
//        .frame(width: mission.size, height: mission.size)
//        .shadow(color: mission.color.opacity(0.2), radius: 8, x: 0, y: 0)
//    }
//}
//
//struct DissolvingBubble: View {
//    let mission: Mission
//    var onComplete: () -> Void
//    @State private var startAnim = false
//    
//    var body: some View {
//        GlassyBubble(mission: mission)
//            .offset(y: startAnim ? -150 : 0)
//            .opacity(startAnim ? 0 : 1)
//            .onAppear {
//                withAnimation(.easeOut(duration: 0.8)) { startAnim = true }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { onComplete() }
//            }
//    }
//}
//
//struct FloatingMissionItem: View {
//    let mission: Mission
//    @State private var xOffset: CGFloat = 0
//    @State private var yOffset: CGFloat = 0
//    
//    var body: some View {
//        GlassyBubble(mission: mission)
//            .offset(x: mission.x + xOffset, y: mission.y + yOffset)
//            .onAppear {
//                withAnimation(.easeInOut(duration: Double.random(in: 3...6)).repeatForever(autoreverses: true)) {
//                    xOffset = CGFloat.random(in: -10...10)
//                }
//                withAnimation(.easeInOut(duration: Double.random(in: 2...5)).repeatForever(autoreverses: true)) {
//                    yOffset = CGFloat.random(in: -15...15)
//                }
//            }
//    }
//}
//
//struct ChatBubbleContainer<Content: View>: View {
//    let content: Content
//    init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }
//    var body: some View {
//        HStack { content; Spacer() }
//            .padding(18)
//            .background(Color.chatLightBg)
//            .cornerRadius(24)
//    }
//}
//
//extension View {
//    func placeholder<Content: View>(
//        when shouldShow: Bool,
//        alignment: Alignment = .leading,
//        @ViewBuilder placeholder: () -> Content) -> some View {
//            
//            ZStack(alignment: alignment) {
//                placeholder().opacity(shouldShow ? 1 : 0)
//                self
//            }
//        }
//    
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape(RoundedCorner(radius: radius, corners: corners))
//    }
//}
//
//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        return Path(path.cgPath)
//    }
//}
//
