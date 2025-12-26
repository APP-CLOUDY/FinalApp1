import SwiftUI
import Combine

@MainActor
class CloudyViewModel: ObservableObject {
    
    // ⚡️ UPDATED: Logic to Auto-Start/Stop Physics based on Screen
    @Published var currentState: AppState = .chatWelcome {
        didSet {
            // If we just switched TO the bubbles screen, Start Engine.
            if case .missionCluster = currentState {
                print("🟢 Entered Cluster: Starting Physics")
                startPhysics()
            }
            // If we switched AWAY (to Welcome or Detail), Stop Engine.
            else {
                print("🔴 Left Cluster: Stopping Physics")
                stopPhysics()
            }
        }
    }
    
    @Published var textInput: String = ""
    @Published var chatHistory: [ChatMessage] = []
    
    @Published var missions: [Mission] = []
    @Published var completedMissionIDs: Set<UUID> = []
    @Published var dissolvingMissionID: UUID? = nil
    @Published var isAIThinking: Bool = false
    @Published var isLoading: Bool = false
    
    // ⚙️ PHYSICS ENGINE STATE
    private var physicsTimer: Timer?
    
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
                
                // Random start positions within a center box
                let randomX = CGFloat.random(in: -100...100)
                let randomY = CGFloat.random(in: -150...150)
                
                return Mission(
                    id: task.id,
                    title: task.title,
                    time: task.frequency,
                    requiresPhoto: task.approval_required ?? false,
                    color: randomColor,
                    size: randomSize,
                    x: randomX,
                    y: randomY
                )
            }
            // Note: We don't need to call startPhysics() here anymore.
            // It will trigger automatically when you tap "Yes, show me!"
            
        } catch {
            print("❌ Failed to load missions: \(error)")
        }
    }
    
    // MARK: - 🫧 Physics Engine
    
    func startPhysics() {
        stopPhysics() // Safety clear
        // Run loop ~50 times a second (0.02s)
        physicsTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateBubblePositions()
            }
        }
    }
    
    func stopPhysics() {
        physicsTimer?.invalidate()
        physicsTimer = nil
    }
    
    func updateBubblePositions() {
        // Define the virtual "Box" size (Screen limits)
        let boxWidth: CGFloat = 320
        let boxHeight: CGFloat = 500
        
        for i in 0..<missions.count {
            let b1 = missions[i]
            
            // 1. Apply Velocity (Movement)
            b1.x += b1.vx
            b1.y += b1.vy
            
            // 2. Wall Bouncing (Keep inside the box)
            // Left & Right
            if b1.x < -boxWidth/2 + b1.size/2 {
                b1.x = -boxWidth/2 + b1.size/2
                b1.vx *= -1 // Flip velocity
            } else if b1.x > boxWidth/2 - b1.size/2 {
                b1.x = boxWidth/2 - b1.size/2
                b1.vx *= -1
            }
            
            // Top & Bottom
            if b1.y < -boxHeight/2 + b1.size/2 {
                b1.y = -boxHeight/2 + b1.size/2
                b1.vy *= -1
            } else if b1.y > boxHeight/2 - b1.size/2 {
                b1.y = boxHeight/2 - b1.size/2
                b1.vy *= -1
            }
            
            // 3. 💥 Bubble-to-Bubble Collision (Bounce off each other)
            for j in (i + 1)..<missions.count {
                let b2 = missions[j]
                
                let dx = b2.x - b1.x
                let dy = b2.y - b1.y
                let distance = sqrt(dx*dx + dy*dy)
                let minDistance = (b1.size/2 + b2.size/2) // Radius 1 + Radius 2
                
                // If they are touching (Distance < sum of radii)
                if distance < minDistance {
                    // Calculate collision angle
                    let angle = atan2(dy, dx)
                    
                    // Force them apart gently (Spring effect)
                    let force: CGFloat = 0.5 // Adjust this for "bounciness"
                    
                    let fx = cos(angle) * force
                    let fy = sin(angle) * force
                    
                    // Push b1 away from b2
                    b1.vx -= fx
                    b1.vy -= fy
                    
                    // Push b2 away from b1
                    b2.vx += fx
                    b2.vy += fy
                    
                    // Separate them immediately to prevent sticking
                    let overlap = minDistance - distance
                    let separationX = cos(angle) * overlap * 0.5
                    let separationY = sin(angle) * overlap * 0.5
                    
                    b1.x -= separationX
                    b1.y -= separationY
                    b2.x += separationX
                    b2.y += separationY
                }
            }
        }
        
        // Trigger UI update manually since we are modifying class properties
        objectWillChange.send()
    }
    
    // MARK: - Chat Logic
    
    func sendMessage() {
        guard !textInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let userText = textInput
        textInput = ""
        withAnimation { chatHistory.append(ChatMessage(text: userText, isUser: true)) }
        isAIThinking = true
        
        Task {
            // Real AI hookup
            let response = await OllamaAIService.shared.sendMessage(
                userQuery: userText,
                missions: missions,
                rewardsBalance: 100
            )
            
            await MainActor.run {
                withAnimation {
                    chatHistory.append(ChatMessage(text: response, isUser: false))
                    isAIThinking = false
                }
            }
        }
    }
    
    // MARK: - Navigation Logic
    
    func goBack() {
        withAnimation {
            if !chatHistory.isEmpty { chatHistory.removeAll() }
            else if case .missionDetail = currentState { currentState = .missionCluster }
            else if currentState == .missionCluster {
                currentState = .chatWelcome
                // Note: The 'didSet' on currentState will automatically call stopPhysics()
            }
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
