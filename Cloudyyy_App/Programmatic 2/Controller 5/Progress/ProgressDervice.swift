import Foundation
import Supabase

// MARK: - Models
struct ProgressReport: Decodable {
    let total_tasks: Int
    let completed_tasks: Int
    let points_earned: Int
    let current_balance: Int
    let breakdown: [EffortBreakdown]?
}

struct EffortBreakdown: Decodable {
    let name: String
    let count: Int
    let total: Int
}

// MARK: - Service
final class ProgressService {
    static let shared = ProgressService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    func fetchStats(childId: UUID, scope: TimeScope) async throws -> ProgressReport {
        // Map Enum to Days
        let days = (scope == .weekly) ? 7 : 30
        
        let params = ["target_child_id": childId.uuidString, "days_lookback": "\(days)"]
        
        let response = try await client
            .rpc("get_child_progress_report", params: params)
            .execute()
        
        let data = response.data
        let report = try JSONDecoder().decode(ProgressReport.self, from: data)
        return report
    }
}
