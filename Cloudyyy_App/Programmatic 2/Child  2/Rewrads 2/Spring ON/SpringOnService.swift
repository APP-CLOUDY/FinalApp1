import Foundation
import Supabase

nonisolated final class SpringOnService {
    static let shared = SpringOnService()
    private init() {}

    private var client: SupabaseClient {
        SupabaseManager.shared.client
    }

    
    // ✅ ADD THIS
    func fetchSpringOnRewardIds(childId: UUID) async throws -> [UUID] {

        let response: [UUID] = try await client
            .rpc(
                "get_spring_on_reward_id",
                params: [
                    "child_id_input": childId.uuidString
                ]
            )
            .single()
            .execute()
            .value

        return response
        
    }


    struct SpringOnRewardMedia: Decodable {
        let image_url: String
        let points: Int
        let title: String
    }


    func fetchSpringOnRewardMedia(
        rewardId: UUID
    ) async throws -> (url: URL, points: Int, title: String) {

        let response: SpringOnRewardMedia = try await client
            .rpc("get_spring_on_reward_media", params: ["reward_id_input": rewardId])
            .single()
            .execute()
            .value

        guard let url = URL(string: response.image_url) else {
            throw URLError(.badURL)
        }

        return (
            url: url,
            points: response.points,
            title: response.title
        )
    }


    func fetchSpringOnImageURLs(rewardId: UUID) async throws -> [URL] {
        let response = try await client
            .from("rewards")
            .select("image_url")
            .eq("id", value: rewardId.uuidString)
            .single()
            .execute()

        let media = try JSONDecoder().decode(SpringOnRewardMedia.self, from: response.data)
        return [URL(string: media.image_url)].compactMap { $0 }
    }
    func fetchProgress(
        childId: UUID,
        rewardId: UUID
    ) async throws -> SpringOnProgress {

        let response = try await client
            .rpc(
                "get_spring_on_progress",
                params: [
                    "child_id_input": childId.uuidString,
                    "reward_id_input": rewardId.uuidString
                ]
            )
            .execute()

        return try JSONDecoder().decode(
            SpringOnProgress.self,
            from: response.data
        )
    }

    func unlockPieces(
        childId: UUID,
        rewardId: UUID,
        pieces: Int,
        cost: Int
    ) async throws -> UnlockSpringOnResponse {

        let response = try await client
            .rpc(
                "unlock_spring_on_pieces",
                params: [
                    "child_id_input": childId.uuidString,
                    "reward_id_input": rewardId.uuidString,
                    "pieces_input": "\(pieces)",
                    "cost_input": "\(cost)"
                ]
            )
            .execute()

        return try JSONDecoder().decode(
            UnlockSpringOnResponse.self,
            from: response.data
        )
    }


}

