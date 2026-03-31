import SwiftUI
import Combine

@MainActor
class CloudyViewModel: ObservableObject {
    
    // ⚡️ Logic to Auto-Start/Stop Physics AND Reload Data
    @Published var currentState: AppState = .chatWelcome {
        didSet {
            // If we just switched TO the bubbles screen...
            if case .missionCluster = currentState {
                print("🟢 Entered Cluster: Starting Physics & Loading Data")
                startPhysics()
                
                // 🔥 FIX: Force reload missions & rewards every time we enter this screen
                Task {
                    await loadMissions()
                }
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
    
    // ✅ 1. Rewards Data
    @Published var rewardsBalance: Int = 0
    @Published var availableRewards: [RewardItem] = [] // The "Shop" items
    
    // ⚙️ PHYSICS ENGINE STATE
    private var physicsTimer: Timer?
    
    init() {}
    
    // MARK: - 🔄 Data Loading
    func loadMissions() async {
        isLoading = true
        defer { isLoading = false }
        
        // ✅ 2. Load Rewards alongside Missions
        await loadRewards()
        
        do {
            // Using ChildHomeService to get the child's perspective
            let tasks: [ScheduleTaskModelChild] = try await ChildHomeService.shared.fetchSchedule(date: Date())
            
            // Filter out tasks that are already approved or pending
            let actionableTasks = tasks.filter { task in
                let status = task.submission_status ?? "new"
                return status != "approved" && status != "pending"
            }
            
            // Map to Physics Bubbles
            self.missions = actionableTasks.enumerated().map { index, task in
                let randomSize = CGFloat.random(in: 75...110)
                let colors: [Color] = [.neonPink, .neonBlue, .neonGreen, .neonYellow]
                let randomColor = colors.randomElement() ?? .neonBlue
                
                // Random start positions within a center box
                let randomX = CGFloat.random(in: -100...100)
                let randomY = CGFloat.random(in: -150...150)
                
                // Check if Approval is required
                let isApprovalNeeded = task.approval_required ?? true
                
                return Mission(
                    id: task.id,
                    title: task.title,
                    time: task.frequency ?? "Today",
                    requiresPhoto: isApprovalNeeded, // If approval is needed, they MUST take a photo.
                    approvalRequired: isApprovalNeeded,
                    color: randomColor,
                    size: randomSize,
                    x: randomX,
                    y: randomY
                )
            }
            
        } catch {
            print("❌ Failed to load missions: \(error)")
        }
    }
    
    // ✅ 3. Load Rewards (Balance + Shop Items)
    func loadRewards() async {
        do {
            // 1. Get Balance
            let stats = try await ChildHomeService.shared.fetchChildRewardStats()
            self.rewardsBalance = stats.total_stars
            
            // 2. Get Shop Items
            self.availableRewards = try await ChildHomeService.shared.fetchAvailableRewards()
            
            print("💰 Loaded: \(self.rewardsBalance) coins and \(self.availableRewards.count) shop items.")
        } catch {
            print("⚠️ Failed to load rewards: \(error)")
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
            if b1.x < -boxWidth/2 + b1.size/2 {
                b1.x = -boxWidth/2 + b1.size/2
                b1.vx *= -1
            } else if b1.x > boxWidth/2 - b1.size/2 {
                b1.x = boxWidth/2 - b1.size/2
                b1.vx *= -1
            }
            
            if b1.y < -boxHeight/2 + b1.size/2 {
                b1.y = -boxHeight/2 + b1.size/2
                b1.vy *= -1
            } else if b1.y > boxHeight/2 - b1.size/2 {
                b1.y = boxHeight/2 - b1.size/2
                b1.vy *= -1
            }
            
            // 3. Collision Logic
            for j in (i + 1)..<missions.count {
                let b2 = missions[j]
                
                let dx = b2.x - b1.x
                let dy = b2.y - b1.y
                let distance = sqrt(dx*dx + dy*dy)
                let minDistance = (b1.size/2 + b2.size/2)
                
                if distance < minDistance {
                    let angle = atan2(dy, dx)
                    let force: CGFloat = 0.5
                    
                    let fx = cos(angle) * force
                    let fy = sin(angle) * force
                    
                    b1.vx -= fx
                    b1.vy -= fy
                    b2.vx += fx
                    b2.vy += fy
                    
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
        
        // Trigger UI update
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
            // ✅ 4. Use Apple Intelligence for responses
            let response = await AppleAIService.shared.sendMessage(
                userQuery: userText,
                missions: missions,
                rewardsList: self.availableRewards, // <--- Passing the shop items
                rewardsBalance: self.rewardsBalance // <--- Passing the balance
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
