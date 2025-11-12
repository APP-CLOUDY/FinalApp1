//
//  SupabaseManage.swift
//  Cloudyyy_App
//
//  Created by user@5 on 11/11/25.
//

import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    // ✅ Your actual project details (one clean line!)
    private let supabaseURL = URL(string: "https://neqizumxkwaomjvdiwaj.supabase.co")!
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lcWl6dW14a3dhb21qdmRpd2FqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3OTI1NDIsImV4cCI6MjA3ODM2ODU0Mn0.tgauxobCIjqhKrSnV0mAqsFSHIqeth0T8nXtksaw8Sc"  // Must be a single uninterrupted string

    let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
}
