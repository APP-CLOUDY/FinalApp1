//
//  ChildRewardsService.swift
//  Cloudyyy_App
//

import Foundation
import Supabase
import PostgREST


// MARK: - Response Models (MATCHES RPC JSON)

struct ChildRewardsResponse: Decodable {
    let active: [ChildRewardItem]
    let history: [ChildRewardItem]
}

struct ClaimRewardResponse: Decodable {
    let remaining_stars: Int
}


struct ChildRewardItem: Decodable {
    let id: UUID                 // reward_id
    let claim_id: UUID?          // reward_claim_id (nullable)
    let title: String
    let description: String?
    let points: Int
    let image_url: String?
    let claim_limit: String?
    let reward_sub_type: String?
}

// MARK: - Insert Payload (ENCODABLE – REQUIRED BY SUPABASE)

struct RewardClaimInsert: Encodable {
    let reward_id: UUID
    let child_id: UUID
    let redeemed_at: String?
}

// MARK: - Service

final class ChildRewardsService {
    
    static let shared = ChildRewardsService()
    private init() {}
    
    private struct GetChildRewardsWrapper: Decodable {
        let get_child_rewards: ChildRewardsResponse
    }

    func getChildRewards(
        childId: UUID,
        category: String
    ) async throws -> ChildRewardsResponse {

        let response = try await SupabaseManager.shared.client
            .rpc(
                "get_child_rewards",
                params: [
                    "child_id_input": childId.uuidString,
                    "category_input": category
                ]
            )
            .select()
            .execute()

        let data = response.data
        print("🧨 RAW JSON STRING:", String(data: data, encoding: .utf8) ?? "nil")

        return try JSONDecoder().decode(ChildRewardsResponse.self, from: data)
    }

    // 🔹 Claim reward
    func claimReward(
        rewardId: UUID,
        childId: UUID
    ) async throws -> ClaimRewardResponse {

        try await SupabaseManager.shared.client
            .rpc(
                "claim_quick_reward",
                params: [
                    "reward_id_input": rewardId.uuidString,
                    "child_id_input": childId.uuidString
                ]
            )
            .execute()
            .value
    }

}
