//
//  ChildSessionManager.swift
//  Cloudyyy_App
//
//  Created by user@5 on 08/12/25.
//

import Foundation

class ChildSessionManager {
    static let shared = ChildSessionManager()
    
    private let kChildID = "current_child_id"
    private let kChildName = "current_child_name"
    
    // Check if a child is currently logged in
    var isLoggedIn: Bool {
        return currentChildId != nil
    }
    
    var currentChildId: UUID? {
        if let str = UserDefaults.standard.string(forKey: kChildID) {
            return UUID(uuidString: str)
        }
        return nil
    }
    
    var currentChildName: String? {
        return UserDefaults.standard.string(forKey: kChildName)
    }
    
    // Save session after successful code entry
    func saveSession(childId: UUID, name: String) {
        UserDefaults.standard.set(childId.uuidString, forKey: kChildID)
        UserDefaults.standard.set(name, forKey: kChildName)
    }
    
    // Logout
    func clearSession() {
        UserDefaults.standard.removeObject(forKey: kChildID)
        UserDefaults.standard.removeObject(forKey: kChildName)
    }
}
