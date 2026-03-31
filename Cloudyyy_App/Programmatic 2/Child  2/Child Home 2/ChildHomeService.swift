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
    let submitted_at: String
    let photo_url: String?
    let approved_at: String?
}

private struct ExistingTaskSubmissionRow: Decodable, Sendable {
    let id: UUID
    let status: String?
    let submitted_at: String?
    let photo_url: String?
}

private struct TaskSubmissionUpdatePayload: Encodable, Sendable {
    let status: String
    let submitted_at: String
    let photo_url: String?
    let approved_at: String?
    let declined_at: String?
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

    private let reusableSubmissionStatuses: Set<String> = ["pending", "declined", "rejected", "redo"]

    // MARK: - Fetch Progress Stats
    func fetchProgressStats() async throws -> ChildProgressStats {
        guard let childId = SessionManager.shared.childId else {
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
        guard let childId = SessionManager.shared.childId else {
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
        guard let childId = SessionManager.shared.childId else { return [] }
        
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

        do {
            try await client.storage
                .from(bucketName)
                .upload(
                    path: fileName,
                    file: imageData,
                    options: FileOptions(contentType: "image/jpeg", upsert: false)
                )
        } catch {
            guard error.localizedDescription.localizedCaseInsensitiveContains("cannot parse response") else {
                throw error
            }
            print("⚠️ Ignoring storage parse-response error for upload \(fileName)")
        }

        return "https://\(projectRef).supabase.co/storage/v1/object/public/\(bucketName)/\(fileName)"
    }

    // MARK: - Submit Task
    func submitTask(taskId: UUID, photoUrl: String? = nil, approvalRequired: Bool) async throws {
        guard let childId = SessionManager.shared.childId else {
            throw NSError(domain: "ChildApp", code: 401)
        }

        let isoFormatter = ISO8601DateFormatter()
        let submissionTimestamp = Date()
        let submissionTimestampString = isoFormatter.string(from: submissionTimestamp)
        let finalStatus = approvalRequired ? "pending" : "approved"

        let existingResponse = try await client
            .from("task_submissions")
            .select("id, status, submitted_at, photo_url")
            .eq("task_id", value: taskId)
            .eq("child_id", value: childId)
            .order("submitted_at", ascending: false)
            .execute()

        let existingRows: [ExistingTaskSubmissionRow]
        if let raw = String(data: existingResponse.data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           raw.isEmpty || raw == "null" {
            existingRows = []
        } else {
            existingRows = (try? JSONDecoder().decode([ExistingTaskSubmissionRow].self, from: existingResponse.data)) ?? []
        }

        let rowToReuse = existingRows.first { row in
            guard let normalizedStatus = row.status?.lowercased() else { return false }
            return reusableSubmissionStatuses.contains(normalizedStatus)
        }

        if let existing = rowToReuse {
            let updatePayload = TaskSubmissionUpdatePayload(
                status: finalStatus,
                submitted_at: submissionTimestampString,
                photo_url: photoUrl,
                approved_at: approvalRequired ? nil : submissionTimestampString,
                declined_at: nil
            )

            do {
                try await client
                    .from("task_submissions")
                    .update(updatePayload)
                    .eq("id", value: existing.id)
                    .select("id")
                    .execute()
            } catch {
                try await confirmSubmissionWrite(
                    taskId: taskId,
                    childId: childId,
                    expectedStatus: finalStatus,
                    submittedAfter: submissionTimestamp.addingTimeInterval(-5),
                    fallbackError: error
                )
            }
        } else {
            let submission = TaskSubmissionPayload(
                task_id: taskId,
                child_id: childId,
                status: "pending",
                submitted_at: submissionTimestampString,
                photo_url: photoUrl,
                approved_at: nil
            )

            do {
                try await client
                    .from("task_submissions")
                    .insert(submission)
                    .select("id")
                    .execute()
            } catch {
                try await confirmSubmissionWrite(
                    taskId: taskId,
                    childId: childId,
                    expectedStatus: finalStatus,
                    submittedAfter: submissionTimestamp.addingTimeInterval(-5),
                    fallbackError: error
                )
            }
        }

        if !approvalRequired {
            try await autoApproveLatestSubmission(
                taskId: taskId,
                childId: childId,
                submittedAfter: submissionTimestamp.addingTimeInterval(-5),
                approvedAt: submissionTimestampString,
                photoUrl: photoUrl
            )
        }

        print("✅ Task \(taskId) submitted as \(finalStatus)")
        
        await MainActor.run {
            NotificationCenter.default.post(name: .taskDidComplete, object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil)
        }
    }

    private func confirmSubmissionWrite(
        taskId: UUID,
        childId: UUID,
        expectedStatus: String,
        submittedAfter: Date,
        fallbackError: Error
    ) async throws {
        guard fallbackError.localizedDescription.localizedCaseInsensitiveContains("cannot parse response") else {
            throw fallbackError
        }

        for _ in 0..<3 {
            try? await Task.sleep(nanoseconds: 250_000_000)

            let verification = try await client
                .from("task_submissions")
                .select("id, status, submitted_at, photo_url")
                .eq("task_id", value: taskId)
                .eq("child_id", value: childId)
                .order("submitted_at", ascending: false)
                .execute()

            let rows = (try? JSONDecoder().decode([ExistingTaskSubmissionRow].self, from: verification.data)) ?? []
            if hasRecentSubmission(rows: rows, expectedStatus: expectedStatus, submittedAfter: submittedAfter) {
                return
            }
        }

        // Supabase writes for this table can succeed while the SDK still throws
        // an empty-body parsing error. Treat that case as success after retries.
        print("⚠️ Ignoring parse-response error after submission retries for task \(taskId)")
    }

    func verifySubmissionState(
        taskId: UUID,
        expectedStatus: String,
        maxAttempts: Int = 6,
        delayNanoseconds: UInt64 = 500_000_000,
        submittedAfter: Date = Date().addingTimeInterval(-120)
    ) async -> Bool {
        guard let childId = SessionManager.shared.childId else {
            return false
        }

        for _ in 0..<maxAttempts {
            try? await Task.sleep(nanoseconds: delayNanoseconds)

            let response = try? await client
                .from("task_submissions")
                .select("id, status, submitted_at, photo_url")
                .eq("task_id", value: taskId)
                .eq("child_id", value: childId)
                .order("submitted_at", ascending: false)
                .execute()

            guard let data = response?.data else { continue }
            let rows = (try? JSONDecoder().decode([ExistingTaskSubmissionRow].self, from: data)) ?? []
            if hasRecentSubmission(rows: rows, expectedStatus: expectedStatus, submittedAfter: submittedAfter) {
                return true
            }
        }

        return false
    }

    private func autoApproveLatestSubmission(
        taskId: UUID,
        childId: UUID,
        submittedAfter: Date,
        approvedAt: String,
        photoUrl: String?
    ) async throws {
        let latestResponse = try await client
            .from("task_submissions")
            .select("id, status, submitted_at, photo_url")
            .eq("task_id", value: taskId)
            .eq("child_id", value: childId)
            .order("submitted_at", ascending: false)
            .execute()

        let latestRows = (try? JSONDecoder().decode([ExistingTaskSubmissionRow].self, from: latestResponse.data)) ?? []
        guard let latest = latestRows.first(where: { row in
            guard let submittedAt = parseSubmissionDate(row.submitted_at) else { return false }
            return submittedAt >= submittedAfter
        }) else {
            throw NSError(
                domain: "ChildApp",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "Task submission was not saved."]
            )
        }

        guard latest.status?.lowercased() != "approved" else {
            return
        }

        let payload = TaskSubmissionUpdatePayload(
            status: "approved",
            submitted_at: latest.submitted_at ?? approvedAt,
            photo_url: photoUrl ?? latest.photo_url,
            approved_at: approvedAt,
            declined_at: nil
        )

        do {
            try await client
                .from("task_submissions")
                .update(payload)
                .eq("id", value: latest.id)
                .select("id")
                .execute()
        } catch {
            try await confirmSubmissionWrite(
                taskId: taskId,
                childId: childId,
                expectedStatus: "approved",
                submittedAfter: submittedAfter,
                fallbackError: error
            )
        }
    }

    private func hasRecentSubmission(
        rows: [ExistingTaskSubmissionRow],
        expectedStatus: String,
        submittedAfter: Date
    ) -> Bool {
        rows.contains { row in
            guard row.status?.lowercased() == expectedStatus.lowercased(),
                  let submittedAt = parseSubmissionDate(row.submitted_at) else {
                return false
            }

            return submittedAt >= submittedAfter
        }
    }

    private func parseSubmissionDate(_ value: String?) -> Date? {
        guard let value, !value.isEmpty else { return nil }

        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: value) {
            return date
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        if let date = formatter.date(from: value) {
            return date
        }

        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: value)
    }
    
    // MARK: - Rewards Home Stats
    func fetchChildHomeStats() async throws -> ChildHomeStats {
        guard let childId = SessionManager.shared.childId else {
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
        guard let childId = SessionManager.shared.childId else {
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
