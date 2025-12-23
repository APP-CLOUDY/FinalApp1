////
////  QuickRewardsProvider.swift
////  Cloudyyy_App
////
////  Created by user@10 on 20/12/25.
////
//
//import Foundation
//import UIKit
//
//// MARK: - Model
//struct QuickRewardItem {
//    let title: String
//    let imageName: String
//    let isEnabled: Bool
//}
//
//
//// MARK: - Provider
//final class QuickRewardsProvider {
//
//    static let shared = QuickRewardsProvider()
//    private init() {}
//
//    func getQuickRewards(assignedTitles: Set<String>) -> [QuickRewardItem] {
//
//        let base: [(title: String, imageName: String, cost: Int)] = [
//
//            ("Gadget Time", "reward_screen_time", 20),
//            ("TV Time", "reward_cartoon", 15),
//
//            ("Snacks", "reward_treat", 25),
//            ("Icecream", "reward_icecream", 30),
//            ("Chocolate", "reward_chocolate", 20),
//            ("Takeaway", "reward_outside_food", 40),
//
//            ("Toys", "reward_toys", 35),
//            ("Outdoor Play", "reward_outdoor", 10),
//
//            ("Surprise", "reward_surprise", 50)
//        ]
//
//        let items = base.map {
//            QuickRewardItem(
//                title: $0.title,
//                imageName: $0.imageName,
//                cost: $0.cost,
//                isEnabled: assignedTitles.contains($0.title)
//            )
//        }
//
//        // 🔑 THIS IS THE IMPORTANT PART
//        return items.sorted {
//            if $0.isEnabled == $1.isEnabled {
//                return false // keep original order
//            }
//            return $0.isEnabled && !$1.isEnabled
//        }
//    }
//
//}
