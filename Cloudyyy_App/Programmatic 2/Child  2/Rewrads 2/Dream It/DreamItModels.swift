import Foundation

struct DreamItProgress: Decodable, Sendable {
    let unlocked_parts: Int
    let total_seconds: Int
    let completed: Bool

    enum CodingKeys: String, CodingKey {
        case unlocked_parts
        case total_seconds
        case completed
    }

    // ✅ NORMAL INIT (ADD THIS)
    init(unlocked_parts: Int, total_seconds: Int, completed: Bool) {
        self.unlocked_parts = unlocked_parts
        self.total_seconds = total_seconds
        self.completed = completed
    }

    // Existing decoder init (keep this)
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        unlocked_parts = try c.decodeIfPresent(Int.self, forKey: .unlocked_parts) ?? 0
        total_seconds    = try c.decodeIfPresent(Int.self, forKey: .total_seconds) ?? 0
        completed        = try c.decodeIfPresent(Bool.self, forKey: .completed) ?? false
    }
}

struct UnlockDreamItResponse: Decodable {
    let unlocked_parts: Int
    let remaining_stars: Int?

    enum CodingKeys: String, CodingKey {
        case unlocked_parts
        case remaining_stars
    }
}


struct DreamObjectPart: Decodable {
    let id: UUID
    let name: String          // maps to display_name AS name
    let iconName: String      // maps to icon_name
    let endSecond: Int        // maps to end_second
    let orderIndex: Int       // maps to order_index

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconName = "icon_name"
        case endSecond = "end_second"
        case orderIndex = "order_index"
    }
}


struct DreamItState {
    let videoURL: URL
    let totalSeconds: Int
    let unlockedparts: Int
    let parts: [DreamObjectPart]
}
