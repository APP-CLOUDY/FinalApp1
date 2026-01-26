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

    // Controls photo logic
    let approval_required: Bool?

    // Parent/Edit View
    let priority: String?
    let list_name: String?
    let due_date: String?
    
    // ✅ NEW FIELDS (Matches SQL Update)
    let due_time: String?
    let repeat_interval: Int?
    let repeat_end_date: String?
    let repeat_on_days: [Int]?
}

struct ChildProgressStats: Decodable, Sendable {
    let total_tasks: Int
    let completed_tasks: Int
    let progress_percent: Double
}

struct TaskSubmissionPayload: Encodable, Sendable {
    let task_id: UUID
    let child_id: UUID
    let status: String
    let submitted_at: Date
    let photo_url: String?
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

// MARK: - 3. Service Class

final class ChildHomeService: Sendable {

    static let shared = ChildHomeService()

    private let projectRef = "neqizumxkwaomjvdiwaj"

    private var client: SupabaseClient {
        SupabaseManager.shared.client
    }

    // MARK: - Fetch Progress Stats
    func fetchProgressStats() async throws -> ChildProgressStats {
        guard let childId = ChildSessionManager.shared.currentChildId else {
            throw NSError(domain: "ChildApp", code: 401, userInfo: [NSLocalizedDescriptionKey: "No child logged in"])
        }

        let params = ChildStatsParams(child_id_input: childId)

        return try await client
            .rpc("get_child_progress_stats", params: params)
            .execute()
            .value
    }

    // MARK: - Fetch Schedule
    func fetchSchedule(date: Date) async throws -> [ScheduleTaskModelChild] {
        guard let childId = ChildSessionManager.shared.currentChildId else {
            print("❌ DEBUG: No Child ID found")
            return []
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let dateString = formatter.string(from: date)

        let params: [String: String] = [
            "child_id_input": childId.uuidString,
            "target_date": dateString
        ]

        print("🚀 Sending to Child DB: ID: \(childId), Date: \(dateString)")

        do {
            let response = try await client
                .rpc("get_child_schedule", params: params)
                .execute()

            let data = response.data
            
            if let json = String(data: data, encoding: .utf8), json == "null" {
                return []
            }

            let decoder = JSONDecoder()
            let tasks = try decoder.decode([ScheduleTaskModelChild].self, from: data)
            
            // 🔥 Deduplicate tasks by ID
            var seenIDs = Set<UUID>()
            let uniqueTasks = tasks.filter { task in
                if seenIDs.contains(task.id) {
                    return false
                } else {
                    seenIDs.insert(task.id)
                    return true
                }
            }
            
            return uniqueTasks

        } catch {
            print("❌ Schedule fetch failed:", error)
            return []
        }
    }

    // MARK: - ✅ NEW: Fetch Available Rewards (Shop)
    // This allows the Chatbot to know what items are available to buy
    func fetchAvailableRewards() async throws -> [RewardItem] {
        guard let childId = ChildSessionManager.shared.currentChildId else { return [] }
        
        // We assume you have a 'get_child_rewards' RPC or can select directly
        // If you don't have the RPC yet, direct select works if RLS policies allow:
        // .from("rewards").select("*").eq("family_id", value: childFamilyId)
        
        // For now, let's assume direct selection based on Family ID which we assume is linked via Child ID in RLS
        // Or if you have a specific RPC 'get_child_rewards', use that.
        // Assuming direct select on 'rewards' table:
        
        let response = try await client
            .from("rewards")
            .select() // Select all fields
            .execute()
            
        let data = response.data
        if let json = String(data: data, encoding: .utf8), json == "null" { return [] }
        
        let decoder = JSONDecoder()
        return try decoder.decode([RewardItem].self, from: data)
    }

    // MARK: - Upload Proof Image
    func uploadProof(image: UIImage, childId: UUID) async throws -> String {

        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image"])
        }

        let fileName = "\(childId.uuidString)/\(UUID().uuidString).jpg"
        let bucketName = "mission-proofs"

        try await client.storage
            .from(bucketName)
            .upload(
                path: fileName,
                file: imageData,
                options: FileOptions(contentType: "image/jpeg", upsert: false)
            )

        return "https://\(projectRef).supabase.co/storage/v1/object/public/\(bucketName)/\(fileName)"
    }

    // MARK: - Submit Task
    func submitTask(taskId: UUID, photoUrl: String? = nil, approvalRequired: Bool) async throws {
        guard let childId = ChildSessionManager.shared.currentChildId else {
            throw NSError(domain: "ChildApp", code: 401)
        }

        let status = approvalRequired ? "pending" : "approved"
        let approvedAt = approvalRequired ? nil : Date()

        let submission = TaskSubmissionPayload(
            task_id: taskId,
            child_id: childId,
            status: status,
            submitted_at: Date(),
            photo_url: photoUrl,
            approved_at: approvedAt
        )

        try await client.from("task_submissions").insert(submission).execute()

        print("✅ Task \(taskId) submitted as \(status)")
        
        await MainActor.run {
            NotificationCenter.default.post(name: .taskDidComplete, object: nil)
        }
    }
    
    // MARK: - Rewards Home Stats
    func fetchChildHomeStats() async throws -> ChildHomeStats {
        guard let childId = ChildSessionManager.shared.currentChildId else {
            throw NSError(domain: "ChildApp", code: 401)
        }
        
        let result: [ChildHomeStats] = try await client
            .rpc("get_child_home_stats", params: ["child_id_input": childId])
            .execute()
            .value
        
        guard let stats = result.first else {
            throw NSError(domain: "Empty home stats", code: 0)
        }
        
        return stats
    }

    // MARK: - Reward Coins Stats
    func fetchChildRewardStats() async throws -> ChildRewardStats {
        guard let childId = ChildSessionManager.shared.currentChildId else {
            throw NSError(domain: "ChildApp", code: 401)
        }

        let stats: ChildRewardStats = try await client
            .rpc(
                "get_child_reward_stats",
                params: ["child_id_input": childId]
            )
            .execute()
            .value

        return stats
    }
}
