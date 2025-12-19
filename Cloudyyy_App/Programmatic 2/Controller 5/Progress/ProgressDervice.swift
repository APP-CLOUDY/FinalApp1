//
//  ProgressDervice.swift
//  Cloudyyy_App
//
//  Created by user@5 on 04/12/25.
//

import Foundation
import Supabase

// MARK: - Models
struct ProgressStats: Decodable, Sendable {
    let missions_done: Int
    let missions_total: Int
    let today_points: Int
    let total_points: Int
    let achievements: [ProgressAchievementModel]
    let efforts: [ProgressEffortModel]
}

struct ProgressAchievementModel: Decodable, Sendable {
    let title: String
    let subtitle: String
}

struct ProgressEffortModel: Decodable, Sendable {
    let title: String
    let done_count: Int
    let total_count: Int
}

// MARK: - Service
final class ProgressService {
    static let shared = ProgressService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    func fetchProgress(for childId: UUID) async throws -> ProgressStats {
        let params = ["child_id_input": childId.uuidString]
        
        let response: ProgressStats = try await client
            .database
            .rpc("get_child_progress_stats", params: params)
            .execute()
            .value
            
        return response
    }
}
