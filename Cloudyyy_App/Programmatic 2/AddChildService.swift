//
//  AddChildService.swift
//  Cloudyyy_App
//
//  Created by user@10 on 19/12/25.
//

import Foundation
import Supabase

// MARK: - Response Model
struct AddChildResponse: Decodable, Sendable {
    let id: UUID
    let join_code: String
}

// MARK: - Service Class

final class ChildService: Sendable {
    static let shared = ChildService()
    
    // Access the shared client
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    func addChild(name: String, nickname: String?, dob: Date, gender: String, familyId: UUID? = nil) async throws -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let dobString = formatter.string(from: dob)

        // ✅ THE FIX: Use a simple Dictionary instead of a custom Struct.
        // Swift Dictionaries are automatically safe for background threads.
        // We convert the UUID to a String manually; Supabase handles the rest.
        let params: [String: String?] = [
            "name_input": name,
            "nickname_input": nickname,
            "birth_date_input": dobString,
            "gender_input": gender,
            "family_id_input": familyId?.uuidString // Convert UUID to String
        ]

        // Execute the RPC call
        let response: AddChildResponse = try await client
            .database
            .rpc("add_child_to_family", params: params)
            .execute()
            .value

        return response.join_code
    }
}
