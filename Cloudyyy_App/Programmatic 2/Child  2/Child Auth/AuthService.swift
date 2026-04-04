import Foundation
import Supabase

// MARK: - Response Model
// Defined globally to be safe
struct ChildLoginResponse: Decodable, Sendable {
    let status: String?
    let child_id: UUID?
    let name: String?
    let error: String?
}

// MARK: - Service Class

final class AuthService: Sendable {
    static let shared = AuthService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    /// Logs in a child using a 6-digit code.
    func loginChild(code: String) async throws -> Bool {
        
        // ✅ FIX: Use a Dictionary instead of a Struct.
        // Dictionaries are automatically 'Sendable', effectively bypassing the error.
        let params = ["code_input": code]
        
        // Call the Database Function
        let response: ChildLoginResponse = try await client
            .rpc("child_login", params: params)
            .execute()
            .value
        
        // Handle Errors returned by SQL
        if let error = response.error {
            print("Login Failed: \(error)")
            return false // Invalid Code
        }
        
        // Handle Success
        if let id = response.child_id, let name = response.name {
            // Save the session via SessionManager
            await MainActor.run {
                SessionManager.shared.signInChild(childId: id, name: name)
            }
            return true
        }
        
        return false
    }
}
