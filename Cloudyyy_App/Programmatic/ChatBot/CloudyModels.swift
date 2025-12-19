import SwiftUI
import Foundation

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

// MARK: - Models
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool // true = Child, false = AI
    let timestamp = Date()
}

struct TaskItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String?
    let points: Int
    let frequency: String?
    let approvalRequired: Bool? // Maps to SQL 'approval_required'
    let dueTime: String?        // Maps to SQL 'due_time' (Postgres sends time as String "14:30:00")
    
    // ⚠️ NOTE: Since 'submission_status' is NOT in your SQL table,
    // we must treat it as optional or handle it via a separate join.
    // If your API calculates this on the fly, keep it. If not, remove it.
    let submissionStatus: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case points
        case frequency
        case approvalRequired = "approval_required" // ✅ Fixes mapping issue
        case dueTime = "due_time"                   // ✅ Fixes mapping issue
        case submissionStatus = "submission_status" // Check if your API actually sends this
    }
}

struct Mission: Identifiable, Equatable {
    let id: UUID // Maps to Backend ID
    let title: String
    let time: String
    
    // Logic: Controls if camera is needed
    let requiresPhoto: Bool
    
    // UI Properties (Randomized)
    let color: Color
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    static func == (lhs: Mission, rhs: Mission) -> Bool {
        return lhs.id == rhs.id
    }
}
