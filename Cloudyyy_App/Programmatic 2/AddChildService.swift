//
//  AddChildService.swift
//  Cloudyyy_App
//
//  Created by user@10 on 19/12/25.
//

import Foundation
import Supabase

// MARK: - Response Model
// We keep this struct for the RESPONSE only.
struct AddChildResponse: Decodable, Sendable {
    let id: UUID
    let join_code: String
}

struct AddChildParams: Sendable {
    let name_input: String
    let nickname_input: String?
    let birth_date_input: String
    let gender_input: String
}

nonisolated extension AddChildParams: Encodable {}

// MARK: - Service Class

final class ChildService {
    static let shared = ChildService()
    
    // Access the shared client
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    func addChild(name: String, nickname: String?, dob: Date, gender: String) async throws -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let dobString = formatter.string(from: dob)

        // ✅ FIX: Allow NULL properly
        let params = AddChildParams(
            name_input: name,
            nickname_input: nickname,   // ← NULL if nil (PERFECT)
            birth_date_input: dobString,
            gender_input: gender
        )


        let response: AddChildResponse = try await client
            .database
            .rpc("add_child_to_family", params: params)
            .execute()
            .value

        return response.join_code
    }
}
// Add Child

