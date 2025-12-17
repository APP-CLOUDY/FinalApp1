import Foundation
import Supabase

// MARK: - 1. Request Models
struct CreateTaskParams: Encodable, Sendable{
    let title_input: String
    let description_input: String?
    let points_input: Int
    let priority_input: String
    let repeat_rule_input: RepeatRulePayload?
    let list_id_input: UUID
    let child_ids_input: [UUID]
    let due_date_input: String?
    let due_time_input: String?
    let approval_required_input: Bool


    enum CodingKeys: String, CodingKey {
        case title_input
        case description_input
        case points_input
        case priority_input
        case repeat_rule_input      // ✅ FIX
        case list_id_input
        case child_ids_input
        case due_date_input
        case due_time_input
        case approval_required_input
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title_input, forKey: .title_input)
        try container.encode(description_input, forKey: .description_input)
        try container.encode(points_input, forKey: .points_input)
        try container.encode(priority_input, forKey: .priority_input)
        try container.encode(repeat_rule_input, forKey: .repeat_rule_input)
        try container.encode(list_id_input, forKey: .list_id_input)
        try container.encode(child_ids_input, forKey: .child_ids_input)
        try container.encode(due_date_input, forKey: .due_date_input)
        try container.encode(due_time_input, forKey: .due_time_input)
        try container.encode(approval_required_input, forKey: .approval_required_input)
    }
}


struct UpdateTaskParams: Encodable,Sendable {
    let task_id_input: UUID
    let title_input: String
    let description_input: String?
    let points_input: Int
    let priority_input: String
    let frequency_input: String
    let list_id_input: UUID
    let child_ids_input: [UUID]
    let due_date_input: String
    let due_time_input: String
    let approval_required_input: Bool


    enum CodingKeys: String, CodingKey {
        case task_id_input
        case title_input
        case description_input
        case points_input
        case priority_input
        case frequency_input
        case list_id_input           // ✅ FIX
        case child_ids_input
        case due_date_input
        case due_time_input
        case approval_required_input
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(task_id_input, forKey: .task_id_input)
        try container.encode(title_input, forKey: .title_input)
        try container.encode(description_input, forKey: .description_input)
        try container.encode(points_input, forKey: .points_input)
        try container.encode(priority_input, forKey: .priority_input)
        try container.encode(frequency_input, forKey: .frequency_input)
        try container.encode(list_id_input, forKey: .list_id_input)
        try container.encode(child_ids_input, forKey: .child_ids_input)
        try container.encode(due_date_input, forKey: .due_date_input)
        try container.encode(due_time_input, forKey: .due_time_input)
        try container.encode(approval_required_input, forKey: .approval_required_input)
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
struct ScheduleTaskModel: Decodable {
    let id: UUID
    let title: String
    let description: String?
    let points: Int
    let priority: String?
    let submission_status: String?
    let repeat_rule: RepeatRulePayload?
    let due_date: String?
    let approval_required: Bool?

    let list_id: UUID        // ✅ REQUIRED
    let list_name: String    // ✅ REQUIRED for UI
}


// MARK: - Service Class

final class TaskService {
    static let shared = TaskService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    // 1. Create Task (Updated signature)
    func createTask(
        title: String,
        description: String?,
        points: Int,
        priority: String,
        repeatRule: RepeatRule?,    // ✅
        listId: UUID,
        assignTo: [UUID],
        dueDate: Date?,
        approvalRequired: Bool
    ) async throws -> UUID
    
    {
        
        var dateString: String? = nil
        var timeString: String? = nil
        
        if let date = dueDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateString = dateFormatter.string(from: date)
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            timeFormatter.locale = Locale(identifier: "en_US_POSIX")
            timeString = timeFormatter.string(from: date)
        }
        
        let params = CreateTaskParams(
            title_input: title,
            description_input: description,
            points_input: points,
            priority_input: priority,
            repeat_rule_input: repeatRule?.toPayload(),
            list_id_input: listId,
            child_ids_input: assignTo,
            due_date_input: dateString,
            due_time_input: timeString,
            approval_required_input: approvalRequired
        )
        
        
        
        let responses: [TaskResponse] = try await client
            .rpc("create_new_task", params: params)
            .execute()
            .value
        
        guard let response = responses.first else {
            throw NSError(
                domain: "TaskService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No task returned"]
            )
        }
        
        await MainActor.run {
            NotificationCenter.default.post(
                name: NSNotification.Name("DataChanged"),
                object: nil
            )
        }
        
        return response.task_id
    }
    
    // 2. Fetch Schedule (Unchanged)
    func fetchSchedule(for childId: UUID, date: Date) async throws -> [ScheduleTaskModel] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let params: [String: String] = ["child_id_input": childId.uuidString, "target_date": formatter.string(from: date)]
        return try await client.rpc("get_child_schedule", params: params).execute().value
    }
    
    func updateTask(
        taskId: UUID,
        title: String,
        description: String?,
        points: Int,
        priority: String,
        repeatRule: RepeatRule?,
        listId: UUID,
        childIds: [UUID],
        date: Date,
        approvalRequired: Bool
    ) async throws {
        
        let frequency = repeatRule?.displayText.lowercased() ?? "once"
        
        let formatter = DateFormatter()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let params = UpdateTaskParams(
            task_id_input: taskId,
            title_input: title,
            description_input: description,
            points_input: points,
            priority_input: priority,
            frequency_input: frequency,
            list_id_input: listId,                  // ✅ FIX
            child_ids_input: childIds,
            due_date_input: dateFormatter.string(from: date),
            due_time_input: timeFormatter.string(from: date),
            approval_required_input: approvalRequired
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
    // MARK: - Task Lists
    func fetchTaskLists(familyId: UUID) async throws -> [TaskListModel] {
        try await client
            .from("task_lists")
            .select("id, name")
            .eq("family_id", value: familyId.uuidString)
            .order("created_at", ascending: true)
            .execute()
            .value
    }
    
    func createTaskList(name: String, familyId: UUID) async throws -> TaskListModel {
        struct RPCResponse: Decodable {
            let create_or_get_task_list: UUID
        }
        
        let response: RPCResponse = try await client
            .rpc(
                "create_or_get_task_list",
                params: [
                    "p_family_id": familyId.uuidString,
                    "p_name": name
                ]
            )
            .single()
            .execute()
            .value
        
        return TaskListModel(
            id: response.create_or_get_task_list,
            name: name
        )
    }
}
    
extension ScheduleTaskModel {

    var frequencyText: String {
        RepeatRule.fromPayload(repeat_rule).displayText
    }

    var dueDateText: String {
        due_date ?? "No date"
    }
}


