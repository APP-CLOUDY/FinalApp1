import Foundation
import Supabase

// Changed to @unchecked Sendable to resolve strict concurrency warnings
final class SupabaseManager: @unchecked Sendable {
    static let shared = SupabaseManager() 
    let client: SupabaseClient
    
    private init() {
        // Replace these with your actual project details
        let supabaseURL = URL(string: "https://neqizumxkwaomjvdiwaj.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lcWl6dW14a3dhb21qdmRpd2FqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3OTI1NDIsImV4cCI6MjA3ODM2ODU0Mn0.tgauxobCIjqhKrSnV0mAqsFSHIqeth0T8nXtksaw8Sc"
        
        // ✅ FIX: Use .init() to let Swift infer 'AuthClientOptions' automatically.
        // This fixes the "Cannot find type" error while still applying the setting.
        let clientOptions = SupabaseClientOptions(
            auth: .init(emitLocalSessionAsInitialSession: true)
        )
        
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey,
            options: clientOptions
        )
    }
}
