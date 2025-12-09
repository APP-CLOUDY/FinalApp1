import Foundation
import Supabase
import UIKit

// MARK: - 1. Request Models

struct CreateRewardParams: Encodable, Sendable {
    let title_input: String
    let description_input: String
    let points_input: Int
    let category_input: String
    let child_ids_input: [UUID]
    let image_url_input: String?
    let claim_limit_input: String?
    let sub_type_input: String? // ✅ Added

    enum CodingKeys: String, CodingKey {
        case title_input, description_input, points_input, category_input, child_ids_input, image_url_input, claim_limit_input, sub_type_input
    }

    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title_input, forKey: .title_input)
        try container.encode(description_input, forKey: .description_input)
        try container.encode(points_input, forKey: .points_input)
        try container.encode(category_input, forKey: .category_input)
        try container.encode(child_ids_input, forKey: .child_ids_input)
        try container.encode(image_url_input, forKey: .image_url_input)
        try container.encode(claim_limit_input, forKey: .claim_limit_input)
        try container.encode(sub_type_input, forKey: .sub_type_input)
    }
}

struct UpdateRewardParams: Encodable, Sendable {
    let reward_id_input: UUID
    let title_input: String
    let description_input: String
    let points_input: Int
    let category_input: String
    let image_url_input: String?
    let claim_limit_input: String?
    let child_ids_input: [UUID]
    let sub_type_input: String? // ✅ Added
    
    enum CodingKeys: String, CodingKey {
        case reward_id_input, title_input, description_input, points_input, category_input, image_url_input, claim_limit_input, child_ids_input, sub_type_input
    }
    
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reward_id_input, forKey: .reward_id_input)
        try container.encode(title_input, forKey: .title_input)
        try container.encode(description_input, forKey: .description_input)
        try container.encode(points_input, forKey: .points_input)
        try container.encode(category_input, forKey: .category_input)
        try container.encode(image_url_input, forKey: .image_url_input)
        try container.encode(claim_limit_input, forKey: .claim_limit_input)
        try container.encode(child_ids_input, forKey: .child_ids_input)
        try container.encode(sub_type_input, forKey: .sub_type_input)
    }
}

// ... Delete/Assign Params remain same ...
struct DeleteRewardParams: Encodable, Sendable {
    let reward_id_input: UUID
    enum CodingKeys: String, CodingKey { case reward_id_input }
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reward_id_input, forKey: .reward_id_input)
    }
}

struct FetchRewardAssignParams: Encodable, Sendable {
    let reward_id_input: UUID
    enum CodingKeys: String, CodingKey { case reward_id_input }
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reward_id_input, forKey: .reward_id_input)
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
    let claim_limit: String?       // ✅ Added
    let reward_sub_type: String?   // ✅ Added
}

// MARK: - 3. Service Class

final class RewardService: Sendable {
    static let shared = RewardService()
    private var client: SupabaseClient { SupabaseManager.shared.client }
    
    // Fetch Logic
    func fetchRewardStats(for childId: UUID) async throws -> RewardStats {
        let params = ["child_id_input": childId.uuidString]
        return try await client.database.rpc("get_child_reward_stats", params: params).execute().value
    }
    
    func fetchRewards(for childId: UUID, category: String) async throws -> RewardLists {
        let params = ["child_id_input": childId.uuidString, "category_input": category]
        return try await client.database.rpc("get_child_rewards", params: params).execute().value
    }
    
    func fetchAssignments(for rewardId: UUID) async throws -> [UUID] {
        let params = FetchRewardAssignParams(reward_id_input: rewardId)
        return try await client.rpc("get_reward_assignments", params: params).execute().value
    }
    
    // Upload
    private func uploadImage(_ image: UIImage) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.5) else { throw NSError(domain: "Err", code: -1, userInfo: nil) }
        let fileName = "\(UUID().uuidString).jpg"
        let options = FileOptions(contentType: "image/jpeg")
        _ = try await client.storage.from("rewards").upload(fileName, data: data, options: options)
        return try client.storage.from("rewards").getPublicURL(path: fileName).absoluteString
    }
    
    // Create
    func createReward(title: String, description: String, points: Int, category: String, assignTo children: [UUID], image: UIImage?, claimLimit: String?, subType: String?) async throws -> UUID {
        var imageUrl: String? = nil
        if let img = image { imageUrl = try? await uploadImage(img) }
        
        let params = CreateRewardParams(
            title_input: title, description_input: description, points_input: points, category_input: category, child_ids_input: children, image_url_input: imageUrl, claim_limit_input: claimLimit,
            sub_type_input: subType // ✅ Passed
        )
        let response: RewardResponse = try await client.database.rpc("create_new_reward", params: params).execute().value
        await MainActor.run { NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil) }
        return response.reward_id
    }
    
    // Update
    func updateReward(rewardId: UUID, title: String, description: String, points: Int, category: String, assignTo children: [UUID], image: UIImage?, existingImageUrl: String?, claimLimit: String?, subType: String?) async throws {
        var finalImageUrl = existingImageUrl
        if let img = image { finalImageUrl = try? await uploadImage(img) }
        
        let params = UpdateRewardParams(
            reward_id_input: rewardId, title_input: title, description_input: description, points_input: points, category_input: category, image_url_input: finalImageUrl, claim_limit_input: claimLimit, child_ids_input: children,
            sub_type_input: subType // ✅ Passed
        )
        try await client.rpc("update_existing_reward", params: params).execute()
        await MainActor.run { NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil) }
    }
    
    // Delete
    func deleteReward(rewardId: UUID) async throws {
        let params = DeleteRewardParams(reward_id_input: rewardId)
        try await client.rpc("delete_reward_by_id", params: params).execute()
        await MainActor.run { NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil) }
    }
}
