import Foundation
import Supabase

// MARK: - 1. Define Params OUTSIDE the class
// FIX: We use '@unchecked Sendable' to silence the strict concurrency error for this simple data struct.
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

    // FIX: Explicitly mark this function as 'nonisolated' so Swift knows it can run on any thread.
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

// Response model
struct TaskResponse: Decodable, Sendable {
    let task_id: UUID
    let status: String
}

// MARK: - 2. Service Class
final class TaskService: Sendable {
    static let shared = TaskService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    func createTask(
        title: String,
        description: String,
        points: Int,
        priority: String,
        frequency: String,
        assignTo children: [UUID],
        dueDate: Date?
    ) async throws -> UUID {
        
        // Date Formatting
        var dateString: String? = nil
        if let date = dueDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            dateString = formatter.string(from: date)
        }
        
        // Create parameters using the safe struct defined above
        let params = CreateTaskParams(
            title_input: title,
            description_input: description,
            points_input: points,
            priority_input: priority,
            frequency_input: frequency,
            child_ids_input: children,
            due_date_input: dateString
        )
        
        // Call Supabase
        let response: TaskResponse = try await client
            .database
            .rpc("create_new_task", params: params)
            .execute()
            .value
            
        // ✅ ADD THIS LINE: Notify the app that data has changed!
        // This triggers the Home Screen to refresh instantly.
        NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil)
            
        return response.task_id
    }
}
