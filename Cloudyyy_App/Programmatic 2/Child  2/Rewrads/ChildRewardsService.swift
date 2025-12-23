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

struct ChildRewardItem: Decodable {
    let id: UUID
    let title: String
    let description: String?
    let points: Int
    let image_url: String?
    let claim_limit: String?
    let reward_sub_type: String?
    let approval_required: Bool
}

// MARK: - Insert Payload (ENCODABLE – REQUIRED BY SUPABASE)

struct RewardClaimInsert: Encodable {
    let reward_id: UUID
    let child_id: UUID
    let status: String
    let submitted_at: String
    let redeemed_at: String?
}

// MARK: - Service

final class ChildRewardsService {

    static let shared = ChildRewardsService()
    private init() {}

    // 🔹 Fetch rewards for child + category
    func getChildRewards(
        childId: UUID,
        category: String
    ) async throws -> ChildRewardsResponse {

        try await SupabaseManager.shared.client
            .rpc(
                "get_child_rewards",
                params: [
                    "child_id_input": childId.uuidString,
                    "category_input": category
                ]
            )
            .execute()
            .value
    }

    // 🔹 Claim reward
    func claimReward(
        rewardId: UUID,
        childId: UUID,
        approvalRequired: Bool
    ) async throws {

        let now = ISO8601DateFormatter().string(from: Date())

        let payload = RewardClaimInsert(
            reward_id: rewardId,
            child_id: childId,
            status: approvalRequired ? "pending" : "approved",
            submitted_at: now,
            redeemed_at: approvalRequired ? nil : now
        )

        try await SupabaseManager.shared.client
            .from("reward_claims")
            .insert(payload)
            .execute()
    }
}

