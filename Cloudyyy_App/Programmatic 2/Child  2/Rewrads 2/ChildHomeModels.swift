//
//  ChildHomeModels.swift
//  Cloudyyy_App
//
//  Created by user@10 on 19/12/25.
//

import Foundation


// MARK: - Child Home Stats (Dashboard)
struct ChildHomeStats: Decodable {
    let missions_total: Int
    let missions_done: Int
    let pending_count: Int
    let allocated_count: Int
    let redeemed_count: Int
    let current_streak: Int?
    let week_status: [Bool]?
}

// MARK: - Child Reward Stats (Coins)
struct ChildRewardStats: Decodable {
    let total_stars: Int
    let stars_this_week: Int
    let active_rewards: Int
}
