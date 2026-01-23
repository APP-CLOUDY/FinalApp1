import Foundation
import Supabase

// MARK: - Models



// MARK: - Service Class

final class ProfileService: Sendable {
    static let shared = ProfileService()
    
    // REPLACE with your actual project URL
    private let projectURL = "https://neqizumxkwaomjvdiwaj.supabase.co"
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    // MARK: - 1. Fetch Profiles (Read)
    
    // Fetch CHILD Profile
    func fetchChildProfile() async throws -> ChildProfile {
        // Trust the ID stored by your Login Screen
        guard let childIdString = UserDefaults.standard.string(forKey: "current_child_id"),
              let childId = UUID(uuidString: childIdString) else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No Child ID selected."])
        }

        let response = try await client.database
            .from("children")
            .select()
            .eq("id", value: childId)
            .limit(1)
            .execute()
        
        let decoder = JSONDecoder()
        let children = try decoder.decode([ChildProfile].self, from: response.data)
        
        guard let child = children.first else {
            throw NSError(domain: "Database", code: 404, userInfo: [NSLocalizedDescriptionKey: "Child profile not found."])
        }
        
        return child
    }
    
    // Fetch PARENT Profile (Restored to use Session)
        func fetchUserProfile() async throws -> UserProfile {
            
            var parentId: UUID?

            // 1. Priority: Try Supabase Session (This is what worked before!)
            // If the parent logged in, this session object exists.
            if let sessionUser = try? client.auth.session.user {
                print("👤 DEBUG: Found Parent ID from Supabase Session: \(sessionUser.id)")
                parentId = sessionUser.id
            }
            
            // 2. Fallback: Try UserDefaults (For custom flows without session)
            if parentId == nil, let storedId = UserDefaults.standard.string(forKey: "current_parent_id") {
                print("👤 DEBUG: Found Parent ID in UserDefaults: \(storedId)")
                parentId = UUID(uuidString: storedId)
            }
            
            // 3. Validation
            guard let finalId = parentId else {
                print("⚠️ DEBUG: No Parent ID found in Session OR UserDefaults.")
                throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No Parent ID found. Please log in."])
            }
            
            print("🔍 DEBUG: Fetching Parent Profile with ID: \(finalId)")
            
            // 4. Fetch from 'users' table
            let response = try await client.database
                .from("users")
                .select()
                .eq("id", value: finalId)
                .single()
                .execute()
            
            let decoder = JSONDecoder()
            let profile = try decoder.decode(UserProfile.self, from: response.data)
            
            return profile
        }
    // MARK: - 2. Update Data (Write)
    
    func updateChildDetails(name: String, nickname: String, dob: String?) async throws {
        guard let childIdString = UserDefaults.standard.string(forKey: "current_child_id"),
              let childId = UUID(uuidString: childIdString) else { return }
        
        let updates: [String: String?] = ["name": name, "nickname": nickname]
        
        try await client.database
            .from("children")
            .update(updates)
            .eq("id", value: childId)
            .execute()
    }
    
    // Update Avatar (Fixed: Checks Session for Parent)
        func updateAvatar(avatarName: String) async throws {
            
            // CASE A: Is a Child logged in? (Check UserDefaults)
            if let childIdString = UserDefaults.standard.string(forKey: "current_child_id"),
               let childId = UUID(uuidString: childIdString) {
                
                print("🎨 Updating CHILD Avatar to: \(avatarName)")
                try await client.database
                    .from("children")
                    .update(["avatar_url": avatarName])
                    .eq("id", value: childId)
                    .execute()
                return // Done!
            }
            
            // CASE B: Is a Parent logged in? (Check UserDefaults OR Session)
            var parentId: UUID?
            
            // 1. Check UserDefaults
            if let storedId = UserDefaults.standard.string(forKey: "current_parent_id") {
                parentId = UUID(uuidString: storedId)
            }
            
            // 2. Fallback: Check Supabase Session (This catches your current login!)
            if parentId == nil {
                if let sessionUser = try? client.auth.session.user {
                    parentId = sessionUser.id
                }
            }
            
            // 3. Perform Update if we found a Parent
            if let validParentId = parentId {
                print("🎨 Updating PARENT Avatar to: \(avatarName)")
                try await client.database
                    .from("users")
                    .update(["avatar_id": avatarName])
                    .eq("id", value: validParentId)
                    .execute()
            }
            else {
                print("❌ Error: No Child OR Parent ID found in UserDefaults or Session")
                throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in."])
            }
        }
    // MARK: - 3. Avatar Helpers
    
    // Child Buckets
    func fetchChildAvatarList() async throws -> [String] {
        let files = try await client.storage.from("child_avatars").list()
        return files.map { $0.name }
    }
    
    func getChildAvatarURL(fileName: String) -> String {
        return "\(projectURL)/storage/v1/object/public/child_avatars/\(fileName)"
    }
    
    // Parent Buckets
    func fetchAvatarList() async throws -> [String] {
        let files = try await client.storage.from("avatars").list()
        return files.map { $0.name }
    }
    
    func getAvatarURL(fileName: String) -> String {
        return "\(projectURL)/storage/v1/object/public/avatars/\(fileName)"
    }
    
    // MARK: - 4. Sign Out
    
    func signOut() async throws {
        // Clear all local IDs
        UserDefaults.standard.removeObject(forKey: "current_child_id")
        UserDefaults.standard.removeObject(forKey: "current_parent_id")
        
        // Try Supabase signout (just in case)
        try? await client.auth.signOut()
    }
}
