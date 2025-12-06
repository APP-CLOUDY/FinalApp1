import Foundation
import Supabase
import UIKit // Needed for UIImage

// MARK: - 1. Request Parameters
// Uses @unchecked Sendable to satisfy Swift 6 concurrency
struct CreateRewardParams: Encodable, @unchecked Sendable {
    let title_input: String
    let description_input: String
    let points_input: Int
    let category_input: String
    let child_ids_input: [UUID]
    let image_url_input: String?
    let claim_limit_input: String?

    enum CodingKeys: String, CodingKey {
        case title_input, description_input, points_input, category_input, child_ids_input, image_url_input, claim_limit_input
    }

    // Explicitly nonisolated to fix Main Actor errors
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title_input, forKey: .title_input)
        try container.encode(description_input, forKey: .description_input)
        try container.encode(points_input, forKey: .points_input)
        try container.encode(category_input, forKey: .category_input)
        try container.encode(child_ids_input, forKey: .child_ids_input)
        try container.encode(image_url_input, forKey: .image_url_input)
        try container.encode(claim_limit_input, forKey: .claim_limit_input)
    }
}

// MARK: - 2. Response Models
struct RewardStats: Decodable, Sendable {
    let total_stars: Int
    let stars_this_week: Int
    let active_rewards: Int
}

struct RewardResponse: Decodable, Sendable {
    let reward_id: UUID
    let status: String
}

struct RewardLists: Decodable, Sendable {
    let active: [RewardItemModel]
    let history: [RewardItemModel]
}

struct RewardItemModel: Decodable, Sendable {
    let id: UUID
    let title: String
    let description: String?
    let points: Int
    let image_url: String?
}

// MARK: - 3. Service Class
final class RewardService: Sendable {
    static let shared = RewardService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    // MARK: - Fetch Stats
    func fetchRewardStats(for childId: UUID) async throws -> RewardStats {
        let params = ["child_id_input": childId.uuidString]
        return try await client.database.rpc("get_child_reward_stats", params: params).execute().value
    }
    
    // MARK: - Fetch Rewards List
    func fetchRewards(for childId: UUID, category: String) async throws -> RewardLists {
        let params = [
            "child_id_input": childId.uuidString,
            "category_input": category
        ]
        return try await client.database.rpc("get_child_rewards", params: params).execute().value
    }
    
    // MARK: - Upload Image (Fixed)
    private func uploadImage(_ image: UIImage) async throws -> String {
        // 1. Compress image to JPEG
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }
        
        // 2. Create a unique file name
        let fileName = "\(UUID().uuidString).jpg"
        
        // 3. Setup Options
        let options = FileOptions(contentType: "image/jpeg")
        
        // 4. Upload using DATA (not File)
        // FIX: Removed 'path:' label to match your SDK version
        _ = try await client.storage.from("rewards").upload(fileName, data: data, options: options)
        
        // 5. Get Public URL (Try both capitalizations if one fails, usually getPublicURL)
        let url = try client.storage.from("rewards").getPublicURL(path: fileName)
        
        return url.absoluteString
    }
    
    // MARK: - Create Reward
    func createReward(
        title: String,
        description: String,
        points: Int,
        category: String,
        assignTo children: [UUID],
        image: UIImage?,
        claimLimit: String?
    ) async throws -> UUID {
        
        var imageUrl: String? = nil
        
        // 1. Upload Image First
        if let img = image {
            do {
                imageUrl = try await uploadImage(img)
            } catch {
                print("Image upload failed: \(error)")
                // Continue without image if upload fails
            }
        }
        
        // 2. Create Params
        let params = CreateRewardParams(
            title_input: title,
            description_input: description,
            points_input: points,
            category_input: category,
            child_ids_input: children,
            image_url_input: imageUrl,
            claim_limit_input: claimLimit
        )
        
        // 3. Call Database
        let response: RewardResponse = try await client
            .database
            .rpc("create_new_reward", params: params)
            .execute()
            .value
            
        // 4. Notify UI
        NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil)
            
        return response.reward_id
    }
}
