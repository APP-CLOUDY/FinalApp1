//
//  ChildActivityService.swift
//  Cloudyyy_App
//
//  Created by user on 06/01/26.
//

import Foundation
import Supabase

// MARK: - Models for Child Activity

struct ChildActivityItem {
    let id: UUID
    let title: String
    let points: Int
    let status: String // "pending", "approved", "declined"
    let date: Date
    let type: ItemType
    
    enum ItemType {
        case task
        case reward
    }
}

// Private Decodable structs to match Supabase response
private struct TaskSubmissionResponse: Decodable {
    let id: UUID
    let status: String
    let submitted_at: String
    let tasks: TaskInfo?
    
    struct TaskInfo: Decodable {
        let title: String
        let points: Int
    }
}

private struct RewardClaimResponse: Decodable {
    let id: UUID
    let status: String
    let submitted_at: String
    let rewards: RewardInfo?
    
    struct RewardInfo: Decodable {
        let title: String
        let points: Int
    }
}

// MARK: - Service

final class ChildActivityService {
    static let shared = ChildActivityService()
    private init() {}
    
    private var client: SupabaseClient {
        SupabaseManager.shared.client
    }
    
    func fetchAllActivity(for childId: UUID) async throws -> [ChildActivityItem] {
        
        // 1. Fetch Tasks & Rewards (Parallel) for the SPECIFIC Child ID
        // Note: We removed the Auth check here. This assumes your database tables
        // have RLS policies that allow reading by ID, or are public.
        
        print("🔍 Service: Querying for Child ID: \(childId)")
        
        async let tasksReq = fetchTasks(childId: childId)
        async let rewardsReq = fetchRewards(childId: childId)
        
        let (tasks, rewards) = try await (tasksReq, rewardsReq)
        
        // 2. Combine and Sort by Date (Newest first)
        let allItems = tasks + rewards
        return allItems.sorted { $0.date > $1.date }
    }
    
    private func fetchTasks(childId: UUID) async throws -> [ChildActivityItem] {
        let response = try await client
            .from("task_submissions")
            .select("id, status, submitted_at, tasks:task_id(title, points)")
            .eq("child_id", value: childId)
            .order("submitted_at", ascending: false)
            .execute()
            
        let rows = try JSONDecoder().decode([TaskSubmissionResponse].self, from: response.data)
        
        return rows.map { row in
            ChildActivityItem(
                id: row.id,
                title: row.tasks?.title ?? "Unknown Task",
                points: row.tasks?.points ?? 0,
                status: row.status,
                date: ISO8601DateFormatter().date(from: row.submitted_at) ?? Date(),
                type: .task
            )
        }
    }
    
    private func fetchRewards(childId: UUID) async throws -> [ChildActivityItem] {
        let response = try await client
            .from("reward_claims")
            .select("id, status, submitted_at, rewards:reward_id(title, points)")
            .eq("child_id", value: childId)
            .order("submitted_at", ascending: false)
            .execute()
            
        let rows = try JSONDecoder().decode([RewardClaimResponse].self, from: response.data)
        
        return rows.map { row in
            ChildActivityItem(
                id: row.id,
                title: row.rewards?.title ?? "Unknown Reward",
                points: row.rewards?.points ?? 0,
                status: row.status,
                date: ISO8601DateFormatter().date(from: row.submitted_at) ?? Date(),
                type: .reward
            )
        }
    }
}
