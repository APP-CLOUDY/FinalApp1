//
//  StreakService.swift
//  Cloudyyy_App
//
//  Created by user@10 on 23/12/25.
//
import Foundation
import Supabase

struct StreakDayResponse: Decodable {
    let day: Int
}

final class StreakService {

    static let shared = StreakService()
    private init() {}

    // MARK: - Calendar dots
    func getMonthStreak(
        childId: UUID,
        month: Int,
        year: Int
    ) async throws -> Set<Int> {

        let params: [String: String] = [
            "child_id_input": childId.uuidString,
            "month_input": String(month),
            "year_input": String(year)
        ]

        let response: [StreakDayResponse] =
            try await SupabaseManager.shared.client
                .rpc("get_child_streak_month", params: params)
                .execute()
                .value

        return Set(response.map { $0.day })
    }

    // MARK: - Streak count
    func getCurrentStreak(
        childId: UUID
    ) async throws -> Int {

        let params: [String: String] = [
            "child_id_input": childId.uuidString
        ]

        return try await SupabaseManager.shared.client
            .rpc("get_child_current_streak", params: params)
            .execute()
            .value
    }
}
