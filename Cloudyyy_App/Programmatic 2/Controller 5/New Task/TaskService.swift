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
    
    // Custom Repeat Fields
    let repeat_interval_input: Int
    let repeat_end_date_input: String?
    let repeat_on_days_input: [Int]?

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
        case repeat_interval_input
        case repeat_end_date_input
        case repeat_on_days_input
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
        try container.encode(repeat_interval_input, forKey: .repeat_interval_input)
        try container.encode(repeat_end_date_input, forKey: .repeat_end_date_input)
        try container.encode(repeat_on_days_input, forKey: .repeat_on_days_input)
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
    
    let repeat_interval_input: Int
    let repeat_end_date_input: String?
    let repeat_on_days_input: [Int]?

    enum CodingKeys: String, CodingKey {
        case task_id_input, title_input, description_input, points_input, priority_input
        case frequency_input, list_id_input, child_ids_input, due_date_input, due_time_input
        case approval_required_input
        case repeat_interval_input
        case repeat_end_date_input
        case repeat_on_days_input
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
        try container.encode(repeat_interval_input, forKey: .repeat_interval_input)
        try container.encode(repeat_end_date_input, forKey: .repeat_end_date_input)
        try container.encode(repeat_on_days_input, forKey: .repeat_on_days_input)
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

// MARK: - 2. Response Models

struct TaskResponse: Decodable, Sendable {
    let task_id: UUID
    let status: String
}

struct ScheduleTaskModel: Decodable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let description: String?
    let points: Int
    let priority: String?
    let frequency: String?
    
    // ✅ FIXED: Added due_time so it can be decoded from DB
    let due_date: String?
    let due_time: String?
    
    let submission_status: String?
    let approval_required: Bool?
    let list_name: String?
    
    let repeat_interval: Int?
    let repeat_end_date: String?
    let repeat_on_days: [Int]?
}

struct TaskListModel: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
}

// MARK: - Service Class

final class TaskService {
    static let shared = TaskService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    // MARK: - Task CRUD
    
    func createTask(
        title: String,
        description: String?,
        points: Int,
        priority: String,
        frequency: String,
        repeatInterval: Int = 1,
        repeatEndDate: Date? = nil,
        repeatDays: [Int]? = nil,
        listId: UUID,
        assignTo: [UUID],
        dueDate: Date?,
        approvalRequired: Bool
    ) async throws -> UUID {
        
        // 1. Format Due Date & Time
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
        
        // 2. Format Repeat End Date
        var repeatEndString: String? = nil
        if let end = repeatEndDate {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            df.locale = Locale(identifier: "en_US_POSIX")
            repeatEndString = df.string(from: end)
        }
        
        // 3. Prepare Params
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
            approval_required_input: approvalRequired,
            repeat_interval_input: repeatInterval,
            repeat_end_date_input: repeatEndString,
            repeat_on_days_input: repeatDays
        )
        
        let response: TaskResponse = try await client
            .rpc("create_task", params: params)
            .execute()
            .value

        guard response.status == "success" else {
            throw NSError(domain: "TaskService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Task creation failed"])
        }

        await MainActor.run {
            NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil)
        }

        return response.task_id
    }
    
    func fetchSchedule(for childId: UUID, date: Date) async throws -> [ScheduleTaskModel] {
        var calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateString = formatter.string(from: normalizedDate)

        // DEBUG
        print("🚀 Fetching Schedule -> Child: \(childId), Date: \(dateString)")

        let params = [
            "child_id_input": childId.uuidString,
            "target_date": dateString
        ]

        let response = try await client
            .rpc("get_child_schedule", params: params)
            .execute()
        
        // DEBUG: Check if 'due_time' is present in raw JSON
        if let str = String(data: response.data, encoding: .utf8) {
            print("📥 RAW RESPONSE: \(str)")
        }
            
        return try JSONDecoder().decode([ScheduleTaskModel].self, from: response.data)
    }

    func updateTask(
            taskId: UUID,
            title: String,
            description: String?,
            points: Int,
            priority: String,
            frequency_input: String,
            repeatInterval: Int = 1,
            repeatEndDate: Date? = nil,
            repeatDays: [Int]? = nil,
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
            
            var repeatEndString: String? = nil
            if let end = repeatEndDate {
                repeatEndString = dateFormatter.string(from: end)
            }
            
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
                approval_required_input: approvalRequired,
                repeat_interval_input: repeatInterval,
                repeat_end_date_input: repeatEndString,
                repeat_on_days_input: repeatDays
            )
            
            try await client.rpc("update_task_with_assignments", params: params).execute()
            await MainActor.run { NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil) }
        }
    
    func deleteTask(taskId: UUID) async throws {
        let params = DeleteTaskParams(task_id_input: taskId)
        try await client.rpc("delete_task_by_id", params: params).execute()
        await MainActor.run { NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil) }
    }
    
    func fetchAssignments(for taskId: UUID) async throws -> [UUID] {
        let params = FetchAssignmentParams(task_id_input: taskId)
        return try await client.rpc("get_task_assignments", params: params).execute().value
    }

    // MARK: - Task Lists Management
    
    func fetchTaskLists(familyId: UUID) async throws -> [TaskListModel] {
        let params = ["p_family_id": familyId.uuidString]
        
        return try await client
            .rpc("fetch_task_lists", params: params)
            .execute()
            .value
    }
    
    func createTaskList(name: String, familyId: UUID) async throws -> TaskListModel {
        let listId: UUID = try await client
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
            id: listId,
            name: name
        )
    }
    
    func deleteTaskList(id: UUID) async throws {
        let params = ["p_list_id": id.uuidString]
        
        try await client
            .rpc("delete_task_list_safely", params: params)
            .execute()
    }
}

// MARK: - Helper Extension
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
