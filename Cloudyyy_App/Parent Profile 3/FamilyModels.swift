//
//  FamilyModels.swift
//  Cloudyyy_App
//
//  Created by user@5 on 16/12/25.
//

import Foundation

struct FamilyInfo: Decodable {
    let id: UUID
    let family_name: String
}

// A unified model for the UI (works for both Parents and Children)
struct FamilyMemberDisplay {
    let id: String
    let name: String
    let role: String
    let avatarUrl: String? // For parents
    let joinCode: String?  // Only for children
    let type: MemberType
    
    enum MemberType {
        case parent
        case child
    }
}
