import SwiftUI
import Foundation
import Combine // 👈 THIS IS THE FIX

// MARK: - App State
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

// MARK: - Chat Models
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool // true = Child, false = AI
    let timestamp = Date()
}

// MARK: - Data Models (Supabase)
struct TaskItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String?
    let points: Int
    let frequency: String?
    let approvalRequired: Bool? // Maps to SQL 'approval_required'
    let dueTime: String?        // Maps to SQL 'due_time'
    
    // ⚠️ NOTE: This maps to the view/query join in Supabase
    let submissionStatus: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case points
        case frequency
        case approvalRequired = "approval_required"
        case dueTime = "due_time"
        case submissionStatus = "submission_status"
    }
}

// MARK: - UI Models (Physics & Bubbles)
class Mission: Identifiable, ObservableObject, Equatable {
    let id: UUID
    let title: String
    let time: String
    
    // Logic: Controls if camera is needed
    let requiresPhoto: Bool
    
    // UI Properties
    let color: Color
    let size: CGFloat
    
    // ⚙️ Physics Properties (Mutable)
    // We use @Published so the View updates automatically when these change
    @Published var x: CGFloat
    @Published var y: CGFloat
    
    // Velocity (Internal Physics State)
    var vx: CGFloat
    var vy: CGFloat
    
    init(id: UUID, title: String, time: String, requiresPhoto: Bool, color: Color, size: CGFloat, x: CGFloat, y: CGFloat) {
        self.id = id
        self.title = title
        self.time = time
        self.requiresPhoto = requiresPhoto
        self.color = color
        self.size = size
        self.x = x
        self.y = y
        
        // Initialize random movement velocity
        self.vx = CGFloat.random(in: -0.8...0.8)
        self.vy = CGFloat.random(in: -0.8...0.8)
    }
    
    static func == (lhs: Mission, rhs: Mission) -> Bool {
        return lhs.id == rhs.id
    }
}
