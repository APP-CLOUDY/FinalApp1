import Foundation
import Supabase

// MARK: - Models
struct HomeStats: Decodable, Sendable {
    let missions_total: Int
    let missions_done: Int
    let pending_count: Int
    let allocated_count: Int
    let redeemed_count: Int
}

struct ChartDataPoint: Decodable, Sendable, Identifiable {
    var id: String { day }
    let day: String
    let completed_count: Int
    let pending_count: Int
}

private struct ApprovedTaskSubmissionDateRow: Decodable, Sendable {
    let submitted_at: String?
}

// MARK: - Service
final class HomeService: Sendable {
    static let shared = HomeService()
    
    private var client: SupabaseClient {
        return SupabaseManager.shared.client
    }
    
    func fetchHomeStats(for childId: UUID) async throws -> HomeStats {
            let params = ["child_id_input": childId.uuidString]
            
            // ⚠️ FIX: Decode as [HomeStats] (Array), not HomeStats (Dictionary)
            let response: [HomeStats] = try await client
                .database.rpc("get_child_home_stats", params: params)
                .execute()
                .value
                
            // Return the first item, or throw an error if empty
            guard let stats = response.first else {
                throw NSError(domain: "HomeService", code: 404, userInfo: [NSLocalizedDescriptionKey: "No stats found for child"])
            }
            
            return stats
        }
    
    // UPDATED: Now accepts timeRange ('weekly' or 'monthly')
    func fetchChartData(for childId: UUID, range: String) async throws -> [ChartDataPoint] {
        let params = [
            "child_id_input": childId.uuidString,
            "time_range": range
        ]
        
        let response: [ChartDataPoint] = try await client
            .database.rpc("get_child_chart_data", params: params).execute().value
        return response
    }

    func fetchApprovedTaskSubmissionDates(for childId: UUID) async throws -> [Date] {
        let response = try await client
            .from("task_submissions")
            .select("submitted_at")
            .eq("child_id", value: childId)
            .eq("status", value: "approved")
            .execute()

        let rows = try JSONDecoder().decode([ApprovedTaskSubmissionDateRow].self, from: response.data)
        return rows.compactMap { row in
            guard let submittedAt = row.submitted_at else { return nil }
            return Self.parseSupabaseDate(submittedAt)
        }
    }

    private static func parseSupabaseDate(_ value: String) -> Date? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: value) {
            return date
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: value) {
            return date
        }

        let fallback = DateFormatter()
        fallback.locale = Locale(identifier: "en_US_POSIX")
        fallback.timeZone = TimeZone(secondsFromGMT: 0)
        fallback.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = fallback.date(from: value) {
            return date
        }

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX",
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]

        for format in formats {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = format
            if let date = formatter.date(from: value) {
                return date
            }
        }

        return nil
    }
}
