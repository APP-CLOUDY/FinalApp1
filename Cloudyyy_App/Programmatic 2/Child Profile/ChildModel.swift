//
//  ChildModel.swift
//  Cloudyyy_App
//
//  Created by user@10 on 28/01/26.
//
import Foundation

struct ChildProfile: Decodable, Sendable {
    let id: UUID
    let name: String
    let nickname: String?   // ✅ This stores "Chore Champion"
    let avatar_url: String? // ✅ Stores "tiger.png"
}
