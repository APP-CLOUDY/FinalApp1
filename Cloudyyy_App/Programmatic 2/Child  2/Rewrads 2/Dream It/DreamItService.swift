import Foundation
import Supabase

nonisolated final class DreamItService {

    static let shared = DreamItService()
    private init() {}

    private var client: SupabaseClient {
        SupabaseManager.shared.client
    }
    func fetchDreamItRewardIds(childId: UUID) async throws -> [UUID] {
        let params = ["child_id_input": childId.uuidString]

        let rows: [DreamItRewardIdRow] =
            try await client
                .rpc("get_dream_it_reward_ids", params: params)
                .execute()
                .value

        return rows.map { $0.id }
    }

    struct DreamItRewardIdRow: Decodable {
        let id: UUID
    }


    // 2️⃣ Fetch Dream It media + metadata
    struct DreamItRewardMedia: Decodable {
        let video_url: String
        let points: Int
        let title: String
        let total_seconds: Int
    }

    func fetchDreamItRewardMedia(
        rewardId: UUID
    ) async throws -> (url: URL, points: Int, title: String, totalSeconds: Int) {

        let rows: [DreamItRewardMedia] = try await client
            .rpc(
                "get_dream_it_reward_media",
                params: ["reward_id_input": rewardId.uuidString]
            )
            .execute()
            .value

        guard let media = rows.first else {
            throw NSError(
                domain: "DreamIt",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Dream It media not found"]
            )
        }

        guard let url = URL(string: media.video_url) else {
            throw URLError(.badURL)
        }

        return (
            url: url,
            points: media.points,
            title: media.title,
            totalSeconds: media.total_seconds
        )
    }



    // 3️⃣ Fetch / auto-create progress
    func fetchProgress(
        childId: UUID,
        rewardId: UUID
    ) async throws -> DreamItProgress {

        let response = try await client
            .rpc(
                "get_dream_it_progress",
                params: [
                    "child_id_input": childId.uuidString,
                    "reward_id_input": rewardId.uuidString
                ]
            )
            .execute()

        return try JSONDecoder().decode(DreamItProgress.self, from: response.data)
    }


    // 4️⃣ Unlock seconds
    func unlockNextPart(
        childId: UUID,
        rewardId: UUID
    ) async throws -> UnlockDreamItResponse {

        let response = try await client
            .rpc(
                "unlock_dream_it_seconds",
                params: [
                    "child_id_input": childId.uuidString,
                    "reward_id_input": rewardId.uuidString
                ]
            )
            .execute()

        // 🔍 RAW DEBUG
        if let raw = String(data: response.data, encoding: .utf8) {
            print("🧪 unlockNextPart RAW:", raw)
        }

        do {
            return try JSONDecoder().decode(
                UnlockDreamItResponse.self,
                from: response.data
            )
        } catch {
            print("❌ Decode failed:", error)
            throw error
        }

    }


    func fetchDreamItParts(rewardId: UUID) async throws -> [DreamObjectPart] {
        let response = try await client
            .rpc(
                "get_dream_it_parts",
                params: ["reward_id_input": rewardId.uuidString]
            )
            .execute()

        return try JSONDecoder().decode([DreamObjectPart].self, from: response.data)
    }

}

