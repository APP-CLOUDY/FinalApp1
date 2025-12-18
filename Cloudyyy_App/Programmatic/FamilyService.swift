import Foundation
import Supabase

// MARK: - RPC RESPONSE MODELS
// Kept these as they are likely specific to this service
struct DashboardData: Decodable, Sendable {
    let family_name: String?
    let parents: [ParentModel]
    let children: [ChildModel]
}

struct ParentModel: Decodable, Sendable {
    let first_name: String
    let role: String
}

struct ChildModel: Decodable, Sendable {
    let id: UUID
    let name: String
    let nickname: String?
    let join_code: String
}

struct CreateFamilyResponse: Decodable, Sendable {
    let id: UUID
}

// ⚠️ NOTE: The following structs are NOT defined here because
// you mentioned they exist in other files.
// - FamilyInfo
// - FamilyMemberDisplay
// - UserProfile

// MARK: - FAMILY SERVICE

final class FamilyService: Sendable {
    
    static let shared = FamilyService()
    private init() {}
    
    /// Cached family id (from dashboard)
    var familyId: UUID?
    
    // Supabase client
    private var client: SupabaseClient {
        SupabaseManager.shared.client
    }
    
    // MARK: - RPC FUNCTIONS
    
    func createFamily(name: String) async throws -> UUID {
        let params: [String: String] = ["name_input": name]
        
        let response: CreateFamilyResponse = try await client
            .database
            .rpc("create_new_family", params: params)
            .execute()
            .value
        
        return response.id
    }
    
    func fetchDashboard() async throws -> DashboardData {
        let response: DashboardData = try await client
            .database
            .rpc("get_family_dashboard")
            .execute()
            .value
        
        // cache for reuse
        // Note: response.family_id isn't in DashboardData, assuming you might want to fetch it separately or add it to DashboardData struct.
        // For now, removing the assignment to avoid error if property missing.
        
        return response
    }
    
    // MARK: - TABLE QUERIES
    
    /// Get family info for logged-in user
    func fetchCurrentFamily() async throws -> FamilyInfo {
        // ✅ FIX: Use 'currentUser' instead of 'session.user'
        guard let userId = client.auth.currentUser?.id else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
        
        struct MemberRow: Decodable {
            let family_id: UUID
        }
        
        let member: MemberRow = try await client.database
            .from("family_members")
            .select("family_id")
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        
        let family: FamilyInfo = try await client.database
            .from("families")
            .select()
            .eq("id", value: member.family_id)
            .single()
            .execute()
            .value
        
        return family
    }
    
    /// Parents + Children list for UI
    func fetchFamilyMembers(familyId: UUID) async throws -> [FamilyMemberDisplay] {
        var displayMembers: [FamilyMemberDisplay] = []
        
        print("🔍 DEBUG: Fetching members for Family ID: \(familyId)")
        
        // --- A. Fetch Parents ---
        struct ParentRow: Decodable {
            let users: UserProfile?
        }
        
        do {
            let parentRows: [ParentRow] = try await client.database
                .from("family_members")
                .select("users:users(*)") // Join users table
                .eq("family_id", value: familyId)
                .not("user_id", operator: .is, value: "null")
                .execute()
                .value
            
            print("✅ DEBUG: Decoded \(parentRows.count) Parent Rows")
            
            for row in parentRows {
                if let user = row.users {
                    // ✅ Uses local helper instead of external ProfileService
                    // FIX: Convert URL to String? to match FamilyMemberDisplay expectation
                    let avatarUrl = user.avatar_id != nil ? getAvatarURL(fileName: user.avatar_id!)?.absoluteString : nil
                    
                    let p = FamilyMemberDisplay(
                        id: user.id.uuidString,
                        name: user.first_name,
                        role: (user.role ?? "Parent").capitalized,
                        avatarUrl: avatarUrl,
                        joinCode: nil,
                        type: .parent
                    )
                    displayMembers.append(p)
                }
            }
        } catch {
            print("❌ DEBUG: Parent Decoding Error: \(error)")
        }
        
        // --- B. Fetch Children ---
        struct ChildRow: Decodable {
            struct ChildData: Decodable {
                let id: UUID
                let name: String
                let join_code: String?
                let gender: String?
            }
            let children: ChildData?
        }
        
        do {
            let childRows: [ChildRow] = try await client.database
                .from("family_members")
                .select("children:children(*)") // Join children table
                .eq("family_id", value: familyId)
                .not("child_id", operator: .is, value: "null")
                .execute()
                .value
            
            print("✅ DEBUG: Decoded \(childRows.count) Child Rows")
            
            for row in childRows {
                if let child = row.children {
                    let gender = child.gender?.lowercased() ?? "male"
                    let avatarName = (gender == "female") ? "avatar-f-1.png" : "avatar-m-1.png"
                    // FIX: Convert URL to String? to match FamilyMemberDisplay expectation
                    let avatarUrl = getAvatarURL(fileName: avatarName)?.absoluteString
                    
                    let c = FamilyMemberDisplay(
                        id: child.id.uuidString,
                        name: child.name,
                        role: "Child",
                        avatarUrl: avatarUrl,
                        joinCode: child.join_code ?? "----",
                        type: .child
                    )
                    displayMembers.append(c)
                }
            }
        } catch {
            print("❌ DEBUG: Child Decoding Error: \(error)")
        }
        
        return displayMembers
    }
    
    // MARK: - Update
    func updateFamilyName(id: UUID, newName: String) async throws {
        try await client.database
            .from("families")
            .update(["family_name": newName])
            .eq("id", value: id)
            .execute()
    }
    
    // MARK: - Helper (Local Avatar Logic)
    private func getAvatarURL(fileName: String) -> URL? {
        // Safe fallback to avoid crashing if ProfileService is missing
        try? client.storage.from("rewards").getPublicURL(path: fileName)
    }
    
    // MARK: - Auth
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func fetchUserProfile() async throws -> UserProfile {
        guard client.auth.currentUser != nil else {
             throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
        return try await client.database.rpc("get_user_profile").execute().value
    }
    
    func deleteAccount() async throws {
        try await client.database.rpc("delete_my_account").execute()
    }
}
