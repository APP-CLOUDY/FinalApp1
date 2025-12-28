import Foundation
import UIKit
import Supabase

// MARK: - 1. Unified Data Model
struct ScheduleTaskModelChild: Decodable, Sendable, Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let points: Int
    let frequency: String
    
    // Child View Specifics
    let submission_status: String? // "approved", "pending", or nil
    
    // ✅ This column from your 'tasks' table now controls the Photo Logic
    let approval_required: Bool?
    
    // Parent/Edit View Specifics
    let priority: String?
    let list_name: String?
    let due_date: String?
}

struct ChildProgressStats: Decodable, Sendable {
    let total_tasks: Int
    let completed_tasks: Int
    let progress_percent: Double
}

struct TaskSubmission: Encodable, Sendable {
    let task_id: UUID
    let child_id: UUID
    let status: String
    let submitted_at: Date
    let photo_url: String?
    
    // ✅ NEW: Added for Instant Approval Logic
    // If approval is NOT required, we set this immediately so charts update.
    let approved_at: Date?
}

// MARK: - 2. Request Parameters
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
    
    // MARK: - Fetch Stats
    func fetchProgressStats() async throws -> ChildProgressStats{
        guard let childId = ChildSessionManager.shared.currentChildId else {
            throw NSError(domain: "ChildApp", code: 401, userInfo: [NSLocalizedDescriptionKey: "No child logged in"])
        }
        let params = ChildStatsParams(child_id_input: childId)
        return try await client.rpc("get_child_progress_stats", params: params).execute().value
    }
    
    // MARK: - Fetch Schedule
    func fetchSchedule(date: Date) async throws -> [ScheduleTaskModelChild] {
        // 1. Check Child ID
        guard let childId = ChildSessionManager.shared.currentChildId else {
            print("❌ DEBUG: No Child ID found in SessionManager!")
            return []
        }
        
        // 2. Format Date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let dateString = formatter.string(from: date)
        
        print("🔍 DEBUG: Fetching for Child: \(childId)")
        print("🔍 DEBUG: Target Date: \(dateString)")
        
        let params = ChildScheduleParams(child_id_input: childId, target_date: dateString)
        
        do {
            // 3. Call Database
            let response = try await client
                .rpc("get_child_schedule", params: params)
                .execute()
            
            let data = response.data
            
            // 4. Print Raw Response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 DEBUG: Raw JSON from DB: \(jsonString)")
            }

            let tasks = try JSONDecoder().decode(
                [ScheduleTaskModelChild].self,
                from: data
            )
            print("✅ DEBUG: Decoded \(tasks.count) tasks.")
            return tasks
            
        } catch {
            print("❌ DEBUG: Error calling Supabase: \(error)")
            throw error
        }
    }
    
    // MARK: - Upload Proof (Image)
    func uploadProof(image: UIImage, childId: UUID) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }
        
        let fileName = "\(childId.uuidString)/\(UUID().uuidString).jpg"
        let bucketName = "mission-proofs"
        
        try await client.storage
            .from(bucketName)
            .upload(path: fileName, file: imageData, options: FileOptions(contentType: "image/jpeg"))
        
        // ⚠️ REPLACE 'YOUR_PROJECT_ID' with your actual Supabase reference ID
        let projectRef = "YOUR_PROJECT_ID"
        return "https://\(projectRef).supabase.co/storage/v1/object/public/\(bucketName)/\(fileName)"
    }
    
    // MARK: - Submit Task (Fixed Logic)
    func submitTask(taskId: UUID, photoUrl: String? = nil, approvalRequired: Bool) async throws {
        guard let childId = ChildSessionManager.shared.currentChildId else {
            throw NSError(domain: "ChildApp", code: 401, userInfo: [NSLocalizedDescriptionKey: "No child logged in"])
        }
        
        // 🔥 FIX: Determine status based on approval setting
        // If approval is NOT required, mark as 'approved' immediately.
        let status = approvalRequired ? "pending" : "approved"
        
        // 🔥 FIX: If auto-approved, set the approved_at date NOW so charts update
        let approvedAt = approvalRequired ? nil : Date()
        
        let submission = TaskSubmission(
            task_id: taskId,
            child_id: childId,
            status: status,
            submitted_at: Date(),
            photo_url: photoUrl,
            approved_at: approvedAt // ✅ Sending this fixes the Chart/Stats
        )
        
        try await client.database
            .from("task_submissions")
            .insert(submission)
            .execute()
            
        print("✅ Task \(taskId) submitted as \(status).")
    }
    
    // MARK: - Home Dashboard (Streak + Missions)
    func fetchHomeDashboardStats() async throws -> ChildHomeStats {
        guard let childId = ChildSessionManager.shared.currentChildId else {
            throw NSError(domain: "ChildApp", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "No child logged in"])
        }

        return try await client
            .rpc(
                "get_child_home_stats",
                params: ["child_id_input": childId]
            )
            .execute()
            .value
    }

    // MARK: - Reward Stats
    func fetchRewardStats() async throws -> ChildRewardStats {
        guard let childId = ChildSessionManager.shared.currentChildId else {
            throw NSError(domain: "ChildApp", code: 401,
                          userInfo: [NSLocalizedDescriptionKey: "No child logged in"])
        }

        return try await client
            .rpc(
                "get_child_reward_stats",
                params: ["child_id_input": childId]
            )
            .execute()
            .value
    }
    
    // MARK: - Rewards Home (Streak + Missions)
    func fetchChildHomeStats(childId: UUID) async throws -> ChildHomeStats {
        try await client
            .rpc(
                "get_child_home_stats",
                params: ["child_id_input": childId]
            )
            .execute()
            .value
    }

    // MARK: - Rewards Coins
    func fetchChildRewardStats(childId: UUID) async throws -> ChildRewardStats {
        try await client
            .rpc(
                "get_child_reward_stats",
                params: ["child_id_input": childId]
            )
            .execute()
            .value
    }

    // MARK: - Child Progress (Dashboard)
    func fetchStats() async throws -> ChildProgressStats {
        guard let childId = ChildSessionManager.shared.currentChildId else {
            throw NSError(domain: "ChildApp", code: 401)
        }

        return try await client
            .rpc(
                "get_child_progress_stats",
                params: ["child_id_input": childId]
            )
            .execute()
            .value
    }
}
