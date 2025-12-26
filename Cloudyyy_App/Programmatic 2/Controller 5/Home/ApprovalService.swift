import Foundation
import Supabase

// MARK: - Decodable Models

private struct TaskSubmissionRow: Decodable {
    let id: UUID
    let submitted_at: String?
    let approved_at: String?
    let declined_at: String?
    let photo_url: String?
    let tasks: TaskRow
}

private struct RewardClaimRow: Decodable {
    let id: UUID
    let submitted_at: String?
    let approved_at: String?
    let redeemed_at: String?
    let rewards: RewardRow
}

private struct TaskRow: Decodable {
    let title: String
    let points: Int
}

private struct RewardRow: Decodable {
    let title: String
    let points: Int
}

// MARK: - Approval Service

final class ApprovalService {

    static let shared = ApprovalService()
    private init() {}

    private var client: SupabaseClient {
        SupabaseManager.shared.client
    }

    // MARK: - FETCH PENDING

    func fetchPending(childId: UUID) async throws -> [[String: String]] {
        async let tasks = fetchPendingTasks(childId: childId)
        async let rewards = fetchPendingRewards(childId: childId)
        return try await tasks + rewards
    }

    private func fetchPendingTasks(childId: UUID) async throws -> [[String: String]] {
        let res = try await client
            .from("task_submissions")
            .select("id, submitted_at, photo_url, tasks:task_id(title, points)")
            .eq("child_id", value: childId)
            .eq("status", value: "pending")
            .execute()

        let rows = try JSONDecoder().decode([TaskSubmissionRow].self, from: res.data)

        return rows.map {
            [
                "id": $0.id.uuidString,
                "type": "task",
                "title": "Task",
                "subtitle": $0.tasks.title,
                "date": "Requested on \(formatDate($0.submitted_at))",
                "points": "\($0.tasks.points) ⭐️",
                "photo_url": $0.photo_url ?? ""
            ]
        }
    }

    private func fetchPendingRewards(childId: UUID) async throws -> [[String: String]] {
        let res = try await client
            .from("reward_claims")
            .select("id, submitted_at, rewards(title, points)")
            .eq("child_id", value: childId)
            .eq("status", value: "pending")
            .execute()

        let rows = try JSONDecoder().decode([RewardClaimRow].self, from: res.data)

        return rows.map {
            [
                "id": $0.id.uuidString,
                "type": "reward",
                "title": "Reward",
                "subtitle": $0.rewards.title,
                "date": "Requested on \(formatDate($0.submitted_at))",
                "points": "\($0.rewards.points) ⭐️"
            ]
        }
    }

    // MARK: - FETCH APPROVED

    func fetchApproved(childId: UUID) async throws -> [[String: String]] {
        // Fetch Approved Tasks
        let taskRes = try await client
            .from("task_submissions")
            .select("id, approved_at, photo_url, tasks:task_id(title, points)")
            .eq("child_id", value: childId)
            .eq("status", value: "approved")
            .execute()

        // Fetch Approved Rewards
        let rewardRes = try await client
            .from("reward_claims")
            .select("id, approved_at, rewards(title, points)")
            .eq("child_id", value: childId)
            .eq("status", value: "approved")
            .execute()

        let taskRows = try JSONDecoder().decode([TaskSubmissionRow].self, from: taskRes.data)
        let rewardRows = try JSONDecoder().decode([RewardClaimRow].self, from: rewardRes.data)

        let tasks = taskRows.map {
            [
                "id": $0.id.uuidString,
                "type": "task",
                "title": "Task",
                "subtitle": $0.tasks.title,
                "date": "Approved on \(formatDate($0.approved_at))",
                "points": "\($0.tasks.points) ⭐️",
                "photo_url": $0.photo_url ?? "" // ✅ Show photo in history too
            ]
        }

        let rewards = rewardRows.map {
            [
                "id": $0.id.uuidString,
                "type": "reward",
                "title": "Reward",
                "subtitle": $0.rewards.title,
                "date": "Approved on \(formatDate($0.approved_at))",
                "points": "\($0.rewards.points) ⭐️"
            ]
        }

        return tasks + rewards
    }

    // MARK: - FETCH REDEEMED / DECLINED (Fixed)

    func fetchRedeemed(childId: UUID) async throws -> [[String: String]] {
        
        // ⚠️ FIX: Use 'status' = 'declined' instead of checking timestamp = ""
        
        // 1. Fetch Declined Tasks
        let taskRes = try await client
            .from("task_submissions")
            .select("id, declined_at, photo_url, tasks:task_id(title, points)")
            .eq("child_id", value: childId)
            .eq("status", value: "declined") // ✅ Correct Filter
            .execute()

        // 2. Fetch Declined Rewards
        let rewardRes = try await client
            .from("reward_claims")
            .select("id, redeemed_at, rewards(title, points)")
            .eq("child_id", value: childId)
            // Note: Rewards might be 'redeemed' or 'declined'.
            // If you want both, use .in("status", ["declined", "redeemed"])
            // For now, let's show "declined" to match the UI tab.
            .eq("status", value: "declined")
            .execute()

        let taskRows = try JSONDecoder().decode([TaskSubmissionRow].self, from: taskRes.data)
        let rewardRows = try JSONDecoder().decode([RewardClaimRow].self, from: rewardRes.data)

        let tasks = taskRows.map {
            [
                "id": $0.id.uuidString,
                "type": "task",
                "title": "Task (Declined)",
                "subtitle": $0.tasks.title,
                "date": "Declined on \(formatDate($0.declined_at))",
                "points": "\($0.tasks.points) ⭐️",
                "photo_url": $0.photo_url ?? ""
            ]
        }

        let rewards = rewardRows.map {
            [
                "id": $0.id.uuidString,
                "type": "reward",
                "title": "Reward (Declined)",
                "subtitle": $0.rewards.title,
                "date": "Declined",
                "points": "\($0.rewards.points) ⭐️"
            ]
        }

        return tasks + rewards
    }

    // MARK: - ACTIONS

    func approve(item: [String: String]) async throws {
        let id = item["id"]!
        let now = ISO8601DateFormatter().string(from: Date())

        if item["type"] == "task" {
            try await client
                .from("task_submissions")
                .update(["status": "approved", "approved_at": now])
                .eq("id", value: id)
                .execute()
        } else {
            try await client
                .from("reward_claims")
                .update(["status": "approved", "approved_at": now])
                .eq("id", value: id)
                .execute()
        }
        // Note: The DB Trigger adds the points automatically now.
    }

    func decline(item: [String: String]) async throws {
        let id = item["id"]!
        let now = ISO8601DateFormatter().string(from: Date())

        if item["type"] == "task" {
            try await client
                .from("task_submissions")
                .update(["status": "declined", "declined_at": now])
                .eq("id", value: id)
                .execute()
        } else {
            try await client
                .from("reward_claims")
                .update(["status": "declined"])
                .eq("id", value: id)
                .execute()
        }
    }
}

// MARK: - Helper

private func formatDate(_ raw: String?) -> String {
    guard let raw else { return "" }
    return String(raw.prefix(10))
}
