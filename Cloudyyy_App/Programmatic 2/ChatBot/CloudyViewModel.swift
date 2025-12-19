import SwiftUI
import Combine

@MainActor
class CloudyViewModel: ObservableObject {
    
    @Published var currentState: AppState = .chatWelcome
    @Published var textInput: String = ""
    @Published var chatHistory: [ChatMessage] = []
    
    @Published var missions: [Mission] = []
    @Published var completedMissionIDs: Set<UUID> = []
    @Published var dissolvingMissionID: UUID? = nil
    @Published var isAIThinking: Bool = false
    @Published var isLoading: Bool = false
    
    init() {}
    
    func loadMissions() async {
        guard missions.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Using ChildHomeService to get the child's perspective
            let tasks: [ScheduleTaskModelChild] = try await ChildHomeService.shared.fetchSchedule(date: Date())
            
            let actionableTasks = tasks.filter { task in
                let status = task.submission_status ?? "new"
                return status != "approved" && status != "pending"
            }
            
            self.missions = actionableTasks.enumerated().map { index, task in
                let randomSize = CGFloat.random(in: 75...110)
                let colors: [Color] = [.neonPink, .neonBlue, .neonGreen, .neonYellow]
                let randomColor = colors.randomElement() ?? .neonBlue
                let randomX = CGFloat.random(in: -140...140)
                let baseY = CGFloat(index * 35) - 50
                let jitterY = CGFloat.random(in: -30...30)
                
                return Mission(
                    id: task.id,
                    title: task.title,
                    time: task.frequency,
                    requiresPhoto: task.approval_required ?? false,
                    color: randomColor,
                    size: randomSize,
                    x: randomX,
                    y: baseY + jitterY
                )
            }
        } catch {
            print("❌ Failed to load missions: \(error)")
        }
    }
    
    func sendMessage() {
        guard !textInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let userText = textInput
        textInput = ""
        withAnimation { chatHistory.append(ChatMessage(text: userText, isUser: true)) }
        isAIThinking = true
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            let response = "I'm ready to help with that task! ☁️"
            await MainActor.run {
                withAnimation {
                    chatHistory.append(ChatMessage(text: response, isUser: false))
                    isAIThinking = false
                }
            }
        }
    }
    
    func goBack() {
        withAnimation {
            if !chatHistory.isEmpty { chatHistory.removeAll() }
            else if case .missionDetail = currentState { currentState = .missionCluster }
            else if currentState == .missionCluster { currentState = .chatWelcome }
        }
    }
    
    func markMissionComplete(_ mission: Mission) {
        completedMissionIDs.insert(mission.id)
        dissolvingMissionID = mission.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation { self.currentState = .missionCluster }
        }
        NotificationCenter.default.post(name: .taskDidComplete, object: nil)
    }
}
