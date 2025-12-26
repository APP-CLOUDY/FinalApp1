import Foundation
import Supabase

// MARK: - Models
struct HomeStats: Decodable, Sendable {
    let missions_total: Int
    let missions_done: Int
    let pending_count: Int
    let allocated_count: Int
    let redeemed_count: Int
}

struct ChartDataPoint: Decodable, Sendable, Identifiable {
    var id: String { day }
    let day: String
    let completed_count: Int
    let pending_count: Int
}

// MARK: - Service
final class HomeService: Sendable {
    static let shared = HomeService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    func fetchHomeStats(for childId: UUID) async throws -> HomeStats {
            let params = ["child_id_input": childId.uuidString]
            
            // ⚠️ FIX: Decode as [HomeStats] (Array), not HomeStats (Dictionary)
            let response: [HomeStats] = try await client
                .database.rpc("get_child_home_stats", params: params)
                .execute()
                .value
                
            // Return the first item, or throw an error if empty
            guard let stats = response.first else {
                throw NSError(domain: "HomeService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No stats found for child"])
            }
            
            return stats
        }
    
    // UPDATED: Now accepts timeRange ('weekly' or 'monthly')
    func fetchChartData(for childId: UUID, range: String) async throws -> [ChartDataPoint] {
        let params = [
            "child_id_input": childId.uuidString,
            "time_range": range
        ]
        
        let response: [ChartDataPoint] = try await client
            .database.rpc("get_child_chart_data", params: params).execute().value
        return response
    }
}
