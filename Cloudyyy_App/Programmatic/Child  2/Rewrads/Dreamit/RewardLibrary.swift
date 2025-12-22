//
//  RewardLibrary.swift
//  Cloudyyy_App
//
//  Created by user@5 on 22/12/25.
//

import Foundation

// MARK: - Models
struct RewardPart {
    let id: String
    let name: String
    let iconName: String
    let price: String
    let targetFrame: Int
}

struct RewardModel {
    let id: String           // Unique ID (e.g., "mtb_01")
    let title: String        // Display name
    let subtitle: String     // Encouragement text
    let folderName: String   // The folder in Assets (e.g., "Cycle")
    let totalFrames: Int     // e.g., 200
    let parts: [RewardPart]  // The assembly pieces
}

// MARK: - Central Library
struct RewardLibrary {
    
    static let allRewards: [RewardModel] = [
        // 1. MOUNTAIN BIKE (Your current design)
        RewardModel(
            id: "mountain_bike",
            title: "Mountain Bike",
            subtitle: "Build your trail-ready ride!",
            folderName: "Cycle", // Matches Assets/Cycle
            totalFrames: 200,
            parts: [
                RewardPart(id: "frame", name: "Frame", iconName: "frame", price: "500", targetFrame: 42),
                RewardPart(id: "fork", name: "Fork", iconName: "fork", price: "300", targetFrame: 100),
                RewardPart(id: "wheel", name: "Wheels", iconName: "wheel", price: "200", targetFrame: 150),
                RewardPart(id: "seat", name: "Seat", iconName: "seat", price: "150", targetFrame: 200)
            ]
        ),
        
        // 2. EXAMPLE: SPEEDSTER CAR (Add details here later)
        RewardModel(
            id: "speedster_car",
            title: "Speedster Car",
            subtitle: "Assemble your racing dream!",
            folderName: "Car", // You would create a "Car" folder in Assets
            totalFrames: 250,
            parts: [
                RewardPart(id: "chassis", name: "Chassis", iconName: "chassis_icon", price: "600", targetFrame: 60),
                RewardPart(id: "engine", name: "Engine", iconName: "engine_icon", price: "800", targetFrame: 120),
                RewardPart(id: "wheels", name: "Racing Wheels", iconName: "car_wheel", price: "400", targetFrame: 180),
                RewardPart(id: "spoiler", name: "Spoiler", iconName: "spoiler_icon", price: "200", targetFrame: 250)
            ]
        )
    ]
    
    // Helper to find a specific model by ID
    static func getReward(byID id: String) -> RewardModel? {
        return allRewards.first { $0.id == id }
    }
}
