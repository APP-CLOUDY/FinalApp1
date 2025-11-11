//  SupabaseManager.swift

import Foundation
import Supabase

class SupabaseManager {
    
    // This is the one and only instance of your client
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    init() {
        let supabaseURL = URL(string: "https://neqizumxkwaomjvdiwaj.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lcWl6dW14a3dhb21qdmRpd2FqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3OTI1NDIsImV4cCI6MjA3ODM2ODU0Mn0.tgauxobCIjqhKrSnV0mAqsFSHIqeth0T8nXtksaw8Sc"
        
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
}
