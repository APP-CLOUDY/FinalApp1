import Foundation
import Supabase

// MARK: - Dashboard & RPC Models
// These are likely NOT in your other file, so we keep them here.
// If you get redeclaration errors for these too, delete them from here.

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
    let id: UUID
    let name: String
    let nickname: String?
    let join_code: String
}

struct CreateFamilyResponse: Decodable, Sendable {
    let id: UUID
}

// ❌ DELETED: FamilyInfo and FamilyMemberDisplay
// (Because they are already in your FamilyModels.swift file)

// MARK: - Service Class

final class FamilyService: Sendable {
    static let shared = FamilyService()
    
    // Access the shared client safely
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    // MARK: - A. RPC Functions (Dashboard & Signup)
    
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
            
        return response
    }
    
    // MARK: - B. Table Functions (Family Members Page)
    
    /// Fetches the Family Name and ID based on the current logged-in user
    func fetchCurrentFamily() async throws -> FamilyInfo {
        // 1. Get Auth User ID
        // ✅ NEW (Fixed)
        let userId = try await client.auth.session.user.id
        
        // 2. Find which family this user belongs to
        struct MemberRow: Decodable { let family_id: UUID }
        
        let memberRow: MemberRow = try await client.database
            .from("family_members")
            .select("family_id")
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        
        // 3. Get the Family details (Name, ID)
        let family: FamilyInfo = try await client.database
            .from("families")
            .select()
            .eq("id", value: memberRow.family_id)
            .single()
            .execute()
            .value
            
        return family
    }
    
    /// Fetches all Parents and Children for the list
    // MARK: - 2. Fetch Members (Updated Debug Version)
        func fetchFamilyMembers(familyId: UUID) async throws -> [FamilyMemberDisplay] {
            var displayMembers: [FamilyMemberDisplay] = []
            
            print("🔍 DEBUG: Fetching members for Family ID: \(familyId)")
            
            // --- A. Fetch Parents ---
            struct ParentResult: Decodable {
                let users: UserProfile?
            }
            
            do {
                let parentRows: [ParentResult] = try await client.database
                    .from("family_members")
                    .select("users:users(*)")
                    .eq("family_id", value: familyId)
                    .not("user_id", operator: .is, value: "null")
                    .execute()
                    .value
                
                print("✅ DEBUG: Found \(parentRows.count) Parents")
                
                for row in parentRows {
                    if let user = row.users {
                        let avatarUrl = user.avatar_id != nil ? ProfileService.shared.getAvatarURL(fileName: user.avatar_id!) : nil
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
                print("❌ DEBUG: Error fetching parents: \(error)")
            }
            
            // --- B. Fetch Children ---
            // FIX: Made gender and join_code OPTIONAL to prevent crashing if missing
            struct ChildResult: Decodable {
                struct ChildData: Decodable {
                    let id: UUID
                    let name: String
                    let join_code: String? // Changed to Optional
                    let gender: String?    // Changed to Optional
                }
                let children: ChildData?
            }
            
            do {
                let childRows: [ChildResult] = try await client.database
                    .from("family_members")
                    .select("children:children(*)")
                    .eq("family_id", value: familyId)
                    .not("child_id", operator: .is, value: "null")
                    .execute()
                    .value
                
                print("✅ DEBUG: Found \(childRows.count) Children")
                
                for row in childRows {
                    if let child = row.children {
                        // Safe Fallback for Gender
                        let gender = child.gender?.lowercased() ?? "male" // Default to male if nil
                        let avatarName = (gender == "female") ? "avatar-f-1.png" : "avatar-m-1.png"
                        let avatarUrl = ProfileService.shared.getAvatarURL(fileName: avatarName)
                        
                        let c = FamilyMemberDisplay(
                            id: child.id.uuidString,
                            name: child.name,
                            role: "Child",
                            avatarUrl: avatarUrl,
                            joinCode: child.join_code ?? "----", // Default text if code missing
                            type: .child
                        )
                        displayMembers.append(c)
                    }
                }
            } catch {
                print("❌ DEBUG: Error fetching children: \(error)")
                // Common error: "keyNotFound" means a column is missing in your DB
            }
            
            return displayMembers
        }
    
    /// Updates the Family Name
    func updateFamilyName(id: UUID, newName: String) async throws {
        try await client.database
            .from("families")
            .update(["family_name": newName])
            .eq("id", value: id)
            .execute()
    }
}
