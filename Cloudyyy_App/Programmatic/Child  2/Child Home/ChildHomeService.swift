import Foundation
import Supabase

// MARK: - 1. Response Models

struct ChildHomeStats: Decodable, Sendable {
    let total_tasks: Int
    let completed_tasks: Int
    let progress_percent: Double
}

// NOTE: ScheduleTaskModel is assumed to be defined in TaskService.swift.
// If not, uncomment the definition below:
/*
struct ScheduleTaskModel: Decodable, Sendable, Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let points: Int
    let priority: String?
    let frequency: String
    let due_date: String?
    let submission_status: String?
    let approval_required: Bool?
    let list_name: String?
}
*/

// MARK: - 2. Request Models (Strictly defined for Swift 6)

struct ChildStatsParams: Encodable, Sendable {
    let child_id_input: UUID
    
    enum CodingKeys: String, CodingKey { case child_id_input }
    
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(child_id_input, forKey: .child_id_input)
    }
}

struct ChildScheduleParams: Encodable, Sendable {
    let child_id_input: UUID
    let target_date: String
    
    enum CodingKeys: String, CodingKey { case child_id_input, target_date }
    
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(child_id_input, forKey: .child_id_input)
        try container.encode(target_date, forKey: .target_date)
    }
}

// MARK: - 3. Service Class

final class ChildHomeService: Sendable {
    static let shared = ChildHomeService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    // MARK: - Fetch Dashboard Stats
    func fetchStats() async throws -> ChildHomeStats {
        // Get current child ID from session
        guard let childId = ChildSessionManager.shared.currentChildId else {
            throw NSError(domain: "ChildApp", code: 401, userInfo: [NSLocalizedDescriptionKey: "No child logged in"])
        }
        
        let params = ChildStatsParams(child_id_input: childId)
        
        let stats: ChildHomeStats = try await client
            .rpc("get_child_progress_stats", params: params)
            .execute()
            .value
            
        return stats
    }
    
    // MARK: - Fetch Schedule (Read-Only)
    func fetchSchedule(date: Date) async throws -> [ScheduleTaskModel] {
        guard let childId = ChildSessionManager.shared.currentChildId else {
            print("⚠️ No Child ID found in Session")
            return []
        }
        
        // Format Date for SQL
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let params = ChildScheduleParams(
            child_id_input: childId,
            target_date: formatter.string(from: date)
        )
        
        // Call SQL Function 'get_child_schedule'
        let tasks: [ScheduleTaskModel] = try await client.database
            .rpc("get_child_schedule", params: params)
            .execute()
            .value
            
        return tasks
    }
}
