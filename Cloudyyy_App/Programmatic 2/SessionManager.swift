import Foundation
import Supabase
import Combine


// MARK: - User Role (Moved from AppTabBarController)
enum UserRole {
    case parent
    case child
}

// MARK: - Session Info
struct UserSessionInfo {
    let role: UserRole
    let parentProfile: UserProfile?
    let childId: UUID?
    let childName: String?
}

@MainActor
final class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published var currentRole: UserRole?
    @Published var parentProfile: UserProfile?
    @Published var childId: UUID?
    @Published var childName: String?
    
    @Published var isAuthenticated: Bool = false
    
    // Persistence keys
    private let kChildID = "current_child_id"
    private let kChildName = "current_child_name"
    private let kActiveRole = "Cloudyyy_ActiveRole"
    
    private let client: SupabaseClient = SupabaseManager.shared.client
    
    private init() {}
    
    // MARK: - Initialize Session
    func initialize() async {
        // 1. Check for Active Role (optional persistence)
        let savedRole = UserDefaults.standard.string(forKey: kActiveRole)
        
        // 2. Try Parent Session (Supabase)
        if let session = try? await client.auth.session {
            do {
                let profile: UserProfile = try await client
                    .from("users")
                    .select()
                    .eq("id", value: session.user.id)
                    .single()
                    .execute()
                    .value
                
                self.parentProfile = profile
                self.currentRole = .parent
                self.isAuthenticated = true
                UserDefaults.standard.set("parent", forKey: kActiveRole)
                return
            } catch {
                print("Failed to fetch parent profile: \(error)")
            }
        }
        
        // 3. Try Child Session (UserDefaults)
        if let idStr = UserDefaults.standard.string(forKey: kChildID),
           let id = UUID(uuidString: idStr),
           let name = UserDefaults.standard.string(forKey: kChildName) {
            
            self.childId = id
            self.childName = name
            self.currentRole = .child
            self.isAuthenticated = true
            UserDefaults.standard.set("child", forKey: kActiveRole)
            return
        }
        
        // No session found
        self.isAuthenticated = false
        self.currentRole = nil
    }
    
    // MARK: - Parent Logic
    func signInParent(email: String, password: String) async throws {
        let session = try await client.auth.signIn(email: email, password: password)
        
        let profile: UserProfile = try await client
            .from("users")
            .select()
            .eq("id", value: session.user.id)
            .single()
            .execute()
            .value
        
        self.parentProfile = profile
        self.currentRole = .parent
        self.isAuthenticated = true
        UserDefaults.standard.set("parent", forKey: kActiveRole)
        
        // Clear child session if any
        clearChildLocalSession()
    }
    
    // MARK: - Child Logic
    func signInChild(childId: UUID, name: String) {
        self.childId = childId
        self.childName = name
        self.currentRole = .child
        self.isAuthenticated = true
        
        UserDefaults.standard.set(childId.uuidString, forKey: kChildID)
        UserDefaults.standard.set(name, forKey: kChildName)
        UserDefaults.standard.set("child", forKey: kActiveRole)
        
        // Parent auth is separate, usually we don't sign out parent 
        // if a child enters their mode, but for clean state we can leave Supabase alone.
    }
    
    // MARK: - Logout
    func signOut() async {
        // Sign out from Supabase (Parent)
        try? await client.auth.signOut()
        
        // Clear local storage
        clearChildLocalSession()
        UserDefaults.standard.removeObject(forKey: kActiveRole)
        
        // Reset state
        self.parentProfile = nil
        self.childId = nil
        self.childName = nil
        self.currentRole = nil
        self.isAuthenticated = false
    }
    
    private func clearChildLocalSession() {
        UserDefaults.standard.removeObject(forKey: kChildID)
        UserDefaults.standard.removeObject(forKey: kChildName)
    }
}
