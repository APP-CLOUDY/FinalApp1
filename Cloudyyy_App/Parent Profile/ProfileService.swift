import Foundation
import Supabase

final class ProfileService: Sendable {
    static let shared = ProfileService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    // MARK: - 1. List All Avatars from Storage
    func fetchAvatarList() async throws -> [String] {
        let files = try await client.storage
            .from("avatars")
            .list()
        
        return files.map { $0.name }
    }
    
    /// MARK: - 2. Get Public URL for an Avatar
    func getAvatarURL(fileName: String) -> String {
        // REPLACE THIS STRING 👇 with your actual URL from Supabase Settings > API
        let projectURL = "https://neqizumxkwaomjvdiwaj.supabase.co"
        
        // This constructs the full link to the image
        return "\(projectURL)/storage/v1/object/public/avatars/\(fileName)"
    }
    
    // MARK: - Fetch User Profile
    func fetchUserProfile() async throws -> UserProfile {
        // FIX: Removed '?' because 'session' is non-optional
        let userId = try await client.auth.session.user.id
        
        let profile: UserProfile = try await client.database
            .from("users")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        
        return profile
    }
    
    // MARK: - Update Avatar ID
    func updateAvatar(avatarName: String) async throws {
        // FIX: Removed '?' here as well
        let userId = try await client.auth.session.user.id
        
        try await client.database
            .from("users")
            .update(["avatar_id": avatarName])
            .eq("id", value: userId)
            .execute()
    }
    
    // MARK: - Sign Out
    func signOut() async throws {
        try await client.auth.signOut()
    }
}
