import Foundation

struct SpringOnProgress: Decodable, Sendable {
    let unlocked_pieces: Int
    let total_pieces: Int
}

struct UnlockSpringOnResponse: Decodable, Sendable {
    let unlocked_pieces: Int
    let remaining_stars: Int
}

