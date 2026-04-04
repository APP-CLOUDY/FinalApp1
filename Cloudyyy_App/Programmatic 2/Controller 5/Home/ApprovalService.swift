import Foundation
import Supabase

// MARK: - Decodable Models

private struct TaskSubmissionRow: Decodable {
    let id: UUID
    let submitted_at: String?
    let approved_at: String?
    let declined_at: String?
    let photo_url: String?
    let status: String?
    let tasks: TaskRow?
}

private struct RewardClaimRow: Decodable {
    let id: UUID
    let submitted_at: String?
    let approved_at: String?
    let declined_at: String?
    let rewards: RewardRow
}

private struct TaskRow: Decodable {
    let title: String?
    let points: Int?
}

private struct RewardRow: Decodable {
    let title: String
    let points: Int
}

// Helper struct to find the child ID before adding points
private struct ChildLookup: Decodable {
    let child_id: UUID
    let task_id: UUID?
    let status: String?
}

private struct SubmissionIdentityRow: Decodable {
    let id: UUID
}

// Helper struct to read current wallet balance
// MARK: - Approval Service

final class ApprovalService: Sendable {

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
        do {
            let res = try await client
                .from("task_submissions")
                .select("id, submitted_at, photo_url, status, tasks:task_id(title, points)")
                .eq("child_id", value: childId)
                .eq("status", value: "pending")
                .execute()

            let rows = try JSONDecoder().decode([TaskSubmissionRow].self, from: res.data)

            return rows.map { row in
                let taskTitle = row.tasks?.title ?? "Unknown Task"
                let taskPoints = row.tasks?.points ?? 0
                
                return [
                    "id": row.id.uuidString,
                    "type": "task",
                    "title": "Task",
                    "subtitle": taskTitle,
                    "date": "Requested on \(formatDate(row.submitted_at))",
                    "points": "\(taskPoints) ⭐️",
                    "photo_url": row.photo_url ?? "",
                    "raw_date": row.submitted_at ?? "" // ✅ Needed for Filter
                ]
            }
        } catch {
            print("❌ ERROR in fetchPendingTasks:", error)
            return []
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
                "points": "\($0.rewards.points) ⭐️",
                "raw_date": $0.submitted_at ?? "" // ✅ Needed for Filter
            ]
        }
    }

    // MARK: - FETCH APPROVED

    func fetchApproved(childId: UUID) async throws -> [[String: String]] {
        // 1. Fetch Approved Tasks
        let taskRes = try await client
            .from("task_submissions")
            .select("id, approved_at, photo_url, tasks:task_id(title, points)")
            .eq("child_id", value: childId)
            .eq("status", value: "approved")
            .order("approved_at", ascending: false)
            .execute()

        // 2. Fetch Approved Rewards
        let rewardRes = try await client
            .from("reward_claims")
            .select("id, approved_at, rewards(title, points)")
            .eq("child_id", value: childId)
            .eq("status", value: "approved")
            .order("approved_at", ascending: false)
            .execute()

        let taskRows = try JSONDecoder().decode([TaskSubmissionRow].self, from: taskRes.data)
        let rewardRows = try JSONDecoder().decode([RewardClaimRow].self, from: rewardRes.data)

        let tasks = taskRows.map { row in
            let title = row.tasks?.title ?? "Unknown Task"
            let points = row.tasks?.points ?? 0
            
            return [
                "id": row.id.uuidString,
                "type": "task",
                "title": "Task",
                "subtitle": title,
                "date": "Approved on \(formatDate(row.approved_at))",
                "points": "\(points) ⭐️",
                "photo_url": row.photo_url ?? "",
                "raw_date": row.approved_at ?? ""
            ]
        }

        let rewards = rewardRows.map {
            [
                "id": $0.id.uuidString,
                "type": "reward",
                "title": "Reward",
                "subtitle": $0.rewards.title,
                "date": "Approved on \(formatDate($0.approved_at))",
                "points": "\($0.rewards.points) ⭐️",
                "raw_date": $0.approved_at ?? ""
            ]
        }

        return (tasks + rewards).sorted {
            ($0["raw_date"] ?? "") > ($1["raw_date"] ?? "")
        }
    }

    // MARK: - FETCH REDO / DECLINED

    func fetchRedeemed(childId: UUID) async throws -> [[String: String]] {
        
        let taskRes = try await client
            .from("task_submissions")
            .select("id, declined_at, photo_url, tasks:task_id(title, points)")
            .eq("child_id", value: childId)
            .eq("status", value: "declined")
            .execute()

        let rewardRes = try await client
            .from("reward_claims")
            .select("id, declined_at, rewards(title, points)")
            .eq("child_id", value: childId)
            .eq("status", value: "declined")
            .execute()

        let taskRows = try JSONDecoder().decode([TaskSubmissionRow].self, from: taskRes.data)
        let rewardRows = try JSONDecoder().decode([RewardClaimRow].self, from: rewardRes.data)

        let tasks = taskRows.map { row in
            let title = row.tasks?.title ?? "Unknown Task"
            let points = row.tasks?.points ?? 0
            
            return [
                "id": row.id.uuidString,
                "type": "task",
                "title": "Task (Redo)",
                "subtitle": title,
                "date": "Redo requested on \(formatDate(row.declined_at))",
                "points": "\(points) ⭐️",
                "photo_url": row.photo_url ?? "",
                "raw_date": row.declined_at ?? ""
            ]
        }

        let rewards = rewardRows.map {
            [
                "id": $0.id.uuidString,
                "type": "reward",
                "title": "Reward (Redo)",
                "subtitle": $0.rewards.title,
                "date": "Redo requested on \(formatDate($0.declined_at))",
                "points": "\($0.rewards.points) ⭐️",
                "raw_date": $0.declined_at ?? ""
            ]
        }

        return (tasks + rewards).sorted {
            ($0["raw_date"] ?? "") > ($1["raw_date"] ?? "")
        }
    }

    // MARK: - ACTIONS (Manual Updates)

    func approve(item: [String: String]) async throws {
        guard let id = item["id"] else { return }
        let now = ISO8601DateFormatter().string(from: Date())

        if item["type"] == "task" {
            // The backend is the source of truth for task approval side effects.
            // We only transition the submission status here to avoid double-crediting points.
            let lookupRes = try await client
                .from("task_submissions")
                .select("child_id, task_id, status")
                .eq("id", value: id)
                .single()
                .execute()
            
            let lookup = try JSONDecoder().decode(ChildLookup.self, from: lookupRes.data)

            if lookup.status?.lowercased() == "approved" {
                return
            }

            if let taskId = lookup.task_id {
                let duplicateRes = try await client
                    .from("task_submissions")
                    .select("id")
                    .eq("child_id", value: lookup.child_id)
                    .eq("task_id", value: taskId)
                    .order("submitted_at", ascending: false)
                    .execute()

                let rows = (try? JSONDecoder().decode([SubmissionIdentityRow].self, from: duplicateRes.data)) ?? []
                for row in rows where row.id.uuidString != id {
                    try? await client
                        .from("task_submissions")
                        .delete()
                        .eq("id", value: row.id)
                        .execute()
                }
            }

            try await client
                .from("task_submissions")
                .update(["status": "approved", "approved_at": now])
                .eq("id", value: id)
                .execute()
            
        } else {
            // Reward Logic: Just mark approved (Points deducted when claimed)
            try await client
                .from("reward_claims")
                .update(["status": "approved", "approved_at": now])
                .eq("id", value: id)
                .execute()
        }
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
            // For Rewards, we just mark as declined.
            // NOTE: If you deduct points on request, you might want to REFUND points here manually like we did in approve().
            try await client
                .from("reward_claims")
                .update(["status": "declined", "declined_at": now])
                .eq("id", value: id)
                .execute()
        }
    }
}

// MARK: - Helper

private func formatDate(_ raw: String?) -> String {
    guard let raw, raw.count >= 10 else { return "" }
    return String(raw.prefix(10))
}
