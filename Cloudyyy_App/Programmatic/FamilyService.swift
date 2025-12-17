import Foundation
import Supabase

// MARK: - RPC RESPONSE MODELS
// Used by get_family_dashboard()

struct DashboardData: Decodable, Sendable {
    let family_id: UUID
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

// ❗ These already exist elsewhere in your project
// DO NOT redeclare them
// - FamilyInfo
// - FamilyMemberDisplay
// - UserProfile
// - ProfileService

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

    // MARK: - RPC FUNCTIONS (You + Friend)

    func createFamily(name: String) async throws -> UUID {
        let params: [String: String] = [
            "name_input": name
        ]

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
        self.familyId = response.family_id
        return response
    }

    // MARK: - TABLE QUERIES (Your Work)

    /// Get family info for logged-in user
    func fetchCurrentFamily() async throws -> FamilyInfo {
        let userId = client.auth.session.user.id

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
        var members: [FamilyMemberDisplay] = []

        // MARK: - Parents

        struct ParentRow: Decodable {
            let users: [UserProfile]?
        }

        let parentRows: [ParentRow] = try await client.database
            .from("family_members")
            .select("users:users(*)")
            .eq("family_id", value: familyId)
            .not("user_id", operator: .is, value: "null")
            .execute()
            .value

        for row in parentRows {
            guard let user = row.users?.first else { continue }

            let avatarUrl = user.avatar_id.map {
                ProfileService.shared.getAvatarURL(fileName: $0)
            }

            members.append(
                FamilyMemberDisplay(
                    id: user.id.uuidString,
                    name: user.first_name,
                    role: (user.role ?? "Parent").capitalized,
                    avatarUrl: avatarUrl,
                    joinCode: nil,
                    type: .parent
                )
            )
        }

        // MARK: - Children

        struct ChildRow: Decodable {
            struct ChildData: Decodable {
                let id: UUID
                let name: String
                let join_code: String?
                let gender: String?
            }
            let children: ChildData?
        }

        let childRows: [ChildRow] = try await client.database
            .from("family_members")
            .select("children:children(*)")
            .eq("family_id", value: familyId)
            .not("child_id", operator: .is, value: "null")
            .execute()
            .value

        for row in childRows {
            guard let child = row.children else { continue }

            let gender = child.gender?.lowercased() ?? "male"
            let avatarName = gender == "female" ? "avatar-f-1.png" : "avatar-m-1.png"
            let avatarUrl = ProfileService.shared.getAvatarURL(fileName: avatarName)

            members.append(
                FamilyMemberDisplay(
                    id: child.id.uuidString,
                    name: child.name,
                    role: "Child",
                    avatarUrl: avatarUrl,
                    joinCode: child.join_code ?? "----",
                    type: .child
                )
            )
        }

        return members
    }

    // MARK: - Update

    func updateFamilyName(id: UUID, newName: String) async throws {
        try await client.database
            .from("families")
            .update(["family_name": newName])
            .eq("id", value: id)
            .execute()
    }
}

