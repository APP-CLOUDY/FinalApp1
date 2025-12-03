import Foundation
import Supabase

// MARK: - Response Models
// These match the JSON returned by your 'get_family_dashboard' SQL function

struct DashboardData: Decodable, Sendable {
    let family_name: String
    let parents: [ParentModel]
    let children: [ChildModel]
}

struct ParentModel: Decodable, Sendable {
    let first_name: String
    let role: String
}

struct ChildModel: Decodable, Sendable {
    let name: String
    let nickname: String?
    let join_code: String
}

// For the Create Family response
struct CreateFamilyResponse: Decodable, Sendable {
    let id: UUID
}

// MARK: - Service Class

final class FamilyService: Sendable {
    static let shared = FamilyService()
    
    // Access the shared client safely
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    // MARK: - Create Family
    func createFamily(name: String) async throws -> UUID {
        // Use [String: String] to avoid "Encodable" errors with 'Any'
        let params: [String: String] = [
            "name_input": name
        ]
        
        // Call the RPC function
        let response: CreateFamilyResponse = try await client
            .database
            .rpc("create_new_family", params: params)
            .execute()
            .value
            
        return response.id
    }
    
    // MARK: - Fetch Dashboard
    func fetchDashboard() async throws -> DashboardData {
        // No params needed; the SQL function uses auth.uid()
        let response: DashboardData = try await client
            .database
            .rpc("get_family_dashboard")
            .execute()
            .value
            
        return response
    }
}
