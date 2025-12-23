import Foundation
import Supabase
import UIKit

// MARK: - 1. Request Models (Defined Globally & Non-isolated)

struct CreateRewardParams: Encodable, Sendable {
    let title_input: String
    let description_input: String
    let points_input: Int
    let category_input: String
    let child_ids_input: [UUID]
    let image_url_input: String?
    let claim_limit_input: String?
    let reward_sub_type_input: String?
    let approval_required_input: Bool?

    enum CodingKeys: String, CodingKey {
        case title_input
        case description_input
        case points_input
        case category_input
        case child_ids_input
        case image_url_input
        case claim_limit_input
        case reward_sub_type_input
        case approval_required_input
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
        try container.encode(reward_sub_type_input, forKey: .reward_sub_type_input)
        if let approval = approval_required_input {
            try container.encode(approval, forKey: .approval_required_input)
        }

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
    let reward_sub_type_input: String?
    let approval_required_input: Bool?

    enum CodingKeys: String, CodingKey {
        case reward_id_input
        case title_input
        case description_input
        case points_input
        case category_input
        case image_url_input
        case claim_limit_input
        case child_ids_input
        case reward_sub_type_input
        case approval_required_input
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
        try container.encode(reward_sub_type_input, forKey: .reward_sub_type_input)
        if let approval = approval_required_input {
            try container.encode(approval, forKey: .approval_required_input)
        }

    }
}


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
    let claim_limit: String?
    let reward_sub_type: String?
    let approval_required: Bool? = nil
}


// MARK: - 3. Service Class

final class RewardService: Sendable {
    static let shared = RewardService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    // MARK: - Fetch Logic
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
    
    // MARK: - Storage Logic
    
    private func uploadImage(_ image: UIImage) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image"])
        }
        let fileName = "\(UUID().uuidString).jpg"
        let options = FileOptions(contentType: "image/jpeg")
        
        // Upload
        _ = try await client.storage.from("rewards").upload(fileName, data: data, options: options)
        
        // ✅ FIX: Added 'try' here because getPublicURL can throw in newer SDK versions
        let url = try client.storage.from("rewards").getPublicURL(path: fileName)
        return url.absoluteString
    }
    
    private func deleteImageFromStorage(url: String) async {
        guard let fileName = url.components(separatedBy: "/").last else { return }
        do {
            _ = try await client.storage.from("rewards").remove(paths: [fileName])
            print("🗑️ Deleted orphaned image: \(fileName)")
        } catch {
            print("⚠️ Failed to delete image: \(error)")
        }
    }
    
    // MARK: - CRUD
    
    func createReward(
        title: String,
        description: String,
        points: Int,
        category: String,
        assignTo children: [UUID],
        image: UIImage?,
        claimLimit: String?,
        subType: String?,
        approvalRequired: Bool?
    ) async throws -> UUID {

        var imageUrl: String? = nil
        if let img = image {
            imageUrl = try? await uploadImage(img)
        }

        let params = CreateRewardParams(
            title_input: title,
            description_input: description,
            points_input: points,
            category_input: category,
            child_ids_input: children,
            image_url_input: imageUrl,
            claim_limit_input: claimLimit,
            reward_sub_type_input: subType,
            approval_required_input: approvalRequired
        )

        // ✅ DECODE AS ARRAY
        let response: [RewardResponse] =
            try await client.database
                .rpc("create_reward", params: params)
                .execute()
                .value

        guard let first = response.first else {
            throw NSError(
                domain: "CreateRewardError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Empty response from create_reward"]
            )
        }

        await MainActor.run {
            NotificationCenter.default.post(
                name: NSNotification.Name("DataChanged"),
                object: nil
            )
        }

        return first.reward_id
    }

    func updateReward(rewardId: UUID, title: String, description: String, points: Int, category: String, assignTo children: [UUID], image: UIImage?, existingImageUrl: String?, claimLimit: String?, subType: String?, approvalRequired:Bool?) async throws {
        
        var finalImageUrl = existingImageUrl
        
        if let img = image {
            // Upload new
            finalImageUrl = try? await uploadImage(img)
            // Cleanup old
            if finalImageUrl != nil, let oldUrl = existingImageUrl {
                await deleteImageFromStorage(url: oldUrl)
            }
        }
        
        let params = UpdateRewardParams(
            reward_id_input: rewardId,
            title_input: title,
            description_input: description,
            points_input: points,
            category_input: category,
            image_url_input: finalImageUrl,
            claim_limit_input: claimLimit,
            child_ids_input: children,
            reward_sub_type_input: subType,
            approval_required_input: approvalRequired
        )
        
        try await client.rpc("update_existing_reward", params: params).execute()
        await MainActor.run { NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil) }
    }
    
    func deleteReward(rewardId: UUID, imageUrl: String? = nil) async throws {
        if let url = imageUrl {
            await deleteImageFromStorage(url: url)
        }
        
        let params = DeleteRewardParams(reward_id_input: rewardId)
        try await client.rpc("delete_reward_by_id", params: params).execute()
        await MainActor.run { NotificationCenter.default.post(name: NSNotification.Name("DataChanged"), object: nil) }
    }
}
