import Foundation
import Supabase

// MARK: - Response Model
// We keep this struct for the RESPONSE only.
struct AddChildResponse: Decodable, Sendable {
    let id: UUID
    let join_code: String
}

// MARK: - Service Class

final class ChildService: Sendable {
    static let shared = ChildService()
    
    // Access the shared client
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    func addChild(name: String, nickname: String?, dob: Date, gender: String) async throws -> String {
        
        // 1. Format Date to String (YYYY-MM-DD)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let dobString = formatter.string(from: dob)
        
        // 2. Create Parameters Dictionary
        // CRITICAL FIX: We explicitly define this as [String: String]
        // This fixes the "Type 'Any' cannot conform to 'Encodable'" error.
        let params: [String: String] = [
            "name_input": name,
            "nickname_input": nickname ?? "",
            "birth_date_input": dobString,
            "gender_input": gender
        ]
        
        // 3. Call the Remote Procedure (RPC)
        let response: AddChildResponse = try await client
            .database
            .rpc("add_child_to_family", params: params)
            .execute()
            .value
            
        return response.join_code
    }
}
