import Foundation
import Supabase

// MARK: - 1. Request Models

struct CreateTaskParams: Encodable, Sendable {
    let title_input: String
    let description_input: String
    let points_input: Int
    let priority_input: String
    let frequency_input: String
    let child_ids_input: [UUID]
    let due_date_input: String?
    let approval_required_input: Bool // ✅ Added

    enum CodingKeys: String, CodingKey {
        case title_input, description_input, points_input, priority_input, frequency_input, child_ids_input, due_date_input, approval_required_input
    }
    
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title_input, forKey: .title_input)
        try container.encode(description_input, forKey: .description_input)
        try container.encode(points_input, forKey: .points_input)
        try container.encode(priority_input, forKey: .priority_input)
        try container.encode(frequency_input, forKey: .frequency_input)
        try container.encode(child_ids_input, forKey: .child_ids_input)
        try container.encode(due_date_input, forKey: .due_date_input)
        try container.encode(approval_required_input, forKey: .approval_required_input) // ✅ Encoded
    }
}

struct UpdateTaskParams: Encodable, Sendable {
    let task_id_input: UUID
    let title_input: String
    let description_input: String
    let points_input: Int
    let priority_input: String
    let frequency_input: String
    let child_ids_input: [UUID]
    let due_date_input: String
    let approval_required_input: Bool // ✅ Added
    
    enum CodingKeys: String, CodingKey {
        case task_id_input, title_input, description_input, points_input, priority_input, frequency_input, child_ids_input, due_date_input, approval_required_input
    }
    
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(task_id_input, forKey: .task_id_input)
        try container.encode(title_input, forKey: .title_input)
        try container.encode(description_input, forKey: .description_input)
        try container.encode(points_input, forKey: .points_input)
        try container.encode(priority_input, forKey: .priority_input)
        try container.encode(frequency_input, forKey: .frequency_input)
        try container.encode(child_ids_input, forKey: .child_ids_input)
        try container.encode(due_date_input, forKey: .due_date_input)
        try container.encode(approval_required_input, forKey: .approval_required_input) // ✅ Encoded
    }
}

// ... DeleteTaskParams and FetchAssignmentParams remain the same ...
struct DeleteTaskParams: Encodable, Sendable {
    let task_id_input: UUID
    enum CodingKeys: String, CodingKey { case task_id_input }
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(task_id_input, forKey: .task_id_input)
    }
}

struct FetchAssignmentParams: Encodable, Sendable {
    let task_id_input: UUID
    enum CodingKeys: String, CodingKey { case task_id_input }
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(task_id_input, forKey: .task_id_input)
    }
}

struct TaskResponse: Decodable, Sendable {
    let task_id: UUID
    let status: String
}

// Keep your ScheduleTaskModel as is (with Optionals)
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

// MARK: - Service Class

final class TaskService: Sendable {
    static let shared = TaskService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    // 1. Create Task (Updated signature)
    func createTask(
        title: String, description: String, points: Int, priority: String, frequency: String, assignTo children: [UUID], dueDate: Date?, approvalRequired: Bool
    ) async throws -> UUID {
        var dateString: String? = nil
        if let date = dueDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            dateString = formatter.string(from: date)
        }
        
        let params = CreateTaskParams(
            title_input: title, description_input: description, points_input: points, priority_input: priority, frequency_input: frequency, child_ids_input: children, due_date_input: dateString,
            approval_required_input: approvalRequired // ✅ Passed
        )
        
        let response: TaskResponse = try await client.database
            .rpc("create_new_task", params: params)
            .execute()
            .value
        
        await MainActor.run { NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil) }
        return response.task_id
    }
    
    // 2. Fetch Schedule (Unchanged)
    func fetchSchedule(for childId: UUID, date: Date) async throws -> [ScheduleTaskModel] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let params: [String: String] = ["child_id_input": childId.uuidString, "target_date": formatter.string(from: date)]
        return try await client.database.rpc("get_child_schedule", params: params).execute().value
    }
    
    // 3. Update Task (Updated signature)
    func updateTask(
        taskId: UUID, title: String, description: String, points: Int, priority: String, frequency: String, childIds: [UUID], date: Date, approvalRequired: Bool
    ) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let params = UpdateTaskParams(
            task_id_input: taskId, title_input: title, description_input: description, points_input: points, priority_input: priority, frequency_input: frequency, child_ids_input: childIds, due_date_input: formatter.string(from: date),
            approval_required_input: approvalRequired // ✅ Passed
        )
        
        try await client.rpc("update_existing_task", params: params).execute()
        await MainActor.run { NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil) }
    }
    
    // 4. Delete Task
    func deleteTask(taskId: UUID) async throws {
        let params = DeleteTaskParams(task_id_input: taskId)
        try await client.rpc("delete_task_by_id", params: params).execute()
        await MainActor.run { NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil) }
    }
    
    // 5. Fetch Assignments
    func fetchAssignments(for taskId: UUID) async throws -> [UUID] {
        let params = FetchAssignmentParams(task_id_input: taskId)
        return try await client.rpc("get_task_assignments", params: params).execute().value
    }
}
