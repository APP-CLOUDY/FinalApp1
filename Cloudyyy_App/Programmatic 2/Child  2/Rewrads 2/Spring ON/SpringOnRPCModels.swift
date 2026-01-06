import Foundation

// ⚠️ NO UIKit
// ⚠️ NO @MainActor

struct SpringOnRewardIdParams: Encodable, Sendable {
    let child_id_input: String
}

struct SpringOnProgressParams: Encodable,Sendable {
    let child_id_input: String
    let reward_id_input: String
}

struct UnlockSpringOnParams: Encodable, @unchecked Sendable {
    let child_id_input: String
    let reward_id_input: String
    let pieces_input: Int
    let cost_input: Int
}

