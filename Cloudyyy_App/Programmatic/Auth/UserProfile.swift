//
//  UserProfile.swift
//  Cloudyyy_App
//
//  Created by user@5 on 17/11/25.
//

// UserProfile.swift
import Foundation

struct UserProfile: Codable {
    let id: UUID
    let first_name: String
    let email: String
    let role: String
    let date_of_birth: String // Must be in "YYYY-MM-DD" format

    // This maps your Swift struct (snake_case) to
    // your database columns (snake_case).
    // In this case, they match, but this is good practice.
    enum CodingKeys: String, CodingKey {
        case id
        case first_name
        case email
        case role
        case date_of_birth
    }
}
