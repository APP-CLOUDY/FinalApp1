//
//  UserProfile.swift
//  Cloudyyy_App
//
//  Created by user@5 on 17/11/25.
//

import Foundation

struct UserProfile: Codable, Sendable {
    let id: UUID
    let first_name: String
    let email: String
    let role: String
    let avatar_id: String? // ✅ Added this
    
    // ✅ Make this Optional (?) because it might be empty in the database
    // format: "YYYY-MM-DD"
    let date_of_birth: String?
    

    // Explicit mapping is good practice, even if names match
    enum CodingKeys: String, CodingKey {
        case id
        case first_name
        case email
        case role
        case date_of_birth
        case avatar_id
    }
}
