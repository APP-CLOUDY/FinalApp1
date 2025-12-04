import Foundation
import Supabase

// MARK: - 1. Shared Models (Must be outside the class)

// --- For Creating Tasks ---
struct CreateTaskParams: Encodable, @unchecked Sendable {
    let title_input: String
    let description_input: String
    let points_input: Int
    let priority_input: String
    let frequency_input: String
    let child_ids_input: [UUID]
    let due_date_input: String?

    enum CodingKeys: String, CodingKey {
        case title_input, description_input, points_input, priority_input, frequency_input, child_ids_input, due_date_input
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
    }
}

struct TaskResponse: Decodable, Sendable {
    let task_id: UUID
    let status: String
}

// --- For Viewing Schedule (Fixes your error) ---
struct ScheduleTaskModel: Decodable, Sendable, Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let points: Int
    let priority: String?
    let frequency: String
    let due_date: String?
    let submission_status: String? // "pending", "approved", or nil
}

// MARK: - 2. Service Class
final class TaskService: Sendable {
    static let shared = TaskService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    // MARK: - Create Task
    func createTask(
        title: String,
        description: String,
        points: Int,
        priority: String,
        frequency: String,
        assignTo children: [UUID],
        dueDate: Date?
    ) async throws -> UUID {
        
        var dateString: String? = nil
        if let date = dueDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            dateString = formatter.string(from: date)
        }
        
        let params = CreateTaskParams(
            title_input: title,
            description_input: description,
            points_input: points,
            priority_input: priority,
            frequency_input: frequency,
            child_ids_input: children,
            due_date_input: dateString
        )
        
        let response: TaskResponse = try await client
            .database
            .rpc("create_new_task", params: params)
            .execute()
            .value
            
        // Notify app to refresh data
        NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil)
            
        return response.task_id
    }
    
    // MARK: - Fetch Schedule (Fixes ViewController error)
    func fetchSchedule(for childId: UUID, date: Date) async throws -> [ScheduleTaskModel] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        // FIX: Explicitly type as [String: String] to ensure safe encoding
        let params: [String: String] = [
            "child_id_input": childId.uuidString,
            "target_date": formatter.string(from: date)
        ]
        
        let response: [ScheduleTaskModel] = try await client
            .database
            .rpc("get_child_schedule", params: params)
            .execute()
            .value
            
        return response
    }
}
