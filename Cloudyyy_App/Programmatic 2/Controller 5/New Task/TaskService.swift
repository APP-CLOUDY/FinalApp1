import Foundation
import Supabase

// MARK: - 1. Request Models
struct CreateTaskParams: Encodable, Sendable {
    let title_input: String
    let description_input: String?
    let points_input: Int
    let priority_input: String
    let frequency_input: String
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
        case frequency_input
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
        try container.encode(frequency_input, forKey: .frequency_input)
        try container.encode(list_id_input, forKey: .list_id_input)
        try container.encode(child_ids_input, forKey: .child_ids_input)
        try container.encode(due_date_input, forKey: .due_date_input)
        try container.encode(due_time_input, forKey: .due_time_input)
        try container.encode(approval_required_input, forKey: .approval_required_input)
    }
}

struct UpdateTaskParams: Encodable, Sendable {
    let task_id_input: UUID
    let title_input: String
    let description_input: String?
    let points_input: Int
    let priority_input: String
    let frequency_input: String
    let list_id_input: UUID
    let child_ids_input: [UUID]
    let due_date_input: String?
    let due_time_input: String?
    let approval_required_input: Bool

    enum CodingKeys: String, CodingKey {
        case task_id_input
        case title_input
        case description_input
        case points_input
        case priority_input
        case frequency_input
        case list_id_input
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

// ✅ UPDATED MODEL: Matches 'get_child_schedule' SQL output exactly
struct ScheduleTaskModel: Decodable, Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let points: Int
    let priority: String?
    let frequency: String?
    let due_date: String?
    
    // New fields required for the View
    let submission_status: String?
    let approval_required: Bool?
    let list_name: String? // Changed to optional to be safe
}

// MARK: - Service Class

final class TaskService {
    static let shared = TaskService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    // 1. Create Task
    func createTask(
        title: String,
        description: String?,
        points: Int,
        priority: String,
        frequency: String,
        listId: UUID,
        assignTo: [UUID],
        dueDate: Date?,
        approvalRequired: Bool
    ) async throws -> UUID {
        
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
            frequency_input: frequency,
            list_id_input: listId,
            child_ids_input: assignTo,
            due_date_input: dateString,
            due_time_input: timeString,
            approval_required_input: approvalRequired
        )
        
        let response: TaskResponse = try await client
            .rpc("create_task", params: params)
            .execute()
            .value

        guard response.status == "success" else {
            throw NSError(domain: "TaskService", code: -1)
        }

        await MainActor.run {
            NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil)
        }

        return response.task_id
    }
    
    // ✅ 2. Fetch Schedule (UPDATED)
    func fetchSchedule(for childId: UUID, date: Date) async throws -> [ScheduleTaskModel] {

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let normalizedDate = calendar.startOfDay(for: date)

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"

        let params = [
            "child_id_input": childId.uuidString,
            "target_date": formatter.string(from: normalizedDate)
        ]

        print("📅 Fetching Parent Schedule for:", formatter.string(from: normalizedDate))

        // Decodes strictly to [ScheduleTaskModel]
        let response = try await client
            .rpc("get_child_schedule", params: params)
            .execute()
            
        return try JSONDecoder().decode([ScheduleTaskModel].self, from: response.data)
    }

    // 3. Update Task
    func updateTask(
        taskId: UUID,
        title: String,
        description: String?,
        points: Int,
        priority: String,
        frequency_input: String,
        listId: UUID,
        childIds: [UUID],
        date: Date,
        approvalRequired: Bool
    ) async throws {
            
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let params = UpdateTaskParams(
            task_id_input: taskId,
            title_input: title,
            description_input: description,
            points_input: points,
            priority_input: priority,
            frequency_input: frequency_input,
            list_id_input: listId,
            child_ids_input: childIds,
            due_date_input: dateFormatter.string(from: date),
            due_time_input: timeFormatter.string(from: date),
            approval_required_input: approvalRequired
        )
        
        try await client.rpc("update_task_with_assignments", params: params).execute()
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
            .execute()
            .value
        
        return TaskListModel(
            id: response.create_or_get_task_list,
            name: name
        )
    }
}

// Helper Extension
extension ScheduleTaskModel {
    var frequencyText: String {
        frequency ?? "Once"
    }

    var dueDateText: String {
        due_date ?? "No date"
    }
    
    var listNameText: String {
        list_name ?? "General"
    }
}
