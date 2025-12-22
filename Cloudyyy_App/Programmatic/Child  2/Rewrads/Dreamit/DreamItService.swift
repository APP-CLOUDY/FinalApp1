////
////  DreamItService.swift
////  Cloudyyy_App
////
////  Created by user@5 on 22/12/25.
////
//
//import Foundation
//import Supabase
//
//final class DreamItService {
//    static let shared = DreamItService()
//    private let client = SupabaseClient(supabaseURL: URL(string: "YOUR_URL")!, supabaseKey: "YOUR_KEY")
//
//    struct ProgressState {
//        let activeModelID: String
//        let unlockedPartOrder: Int
//        let availablePoints: Int
//    }
//
//    // Fetch the current progress for a specific child
//    func fetchCurrentProgress(childID: UUID) async throws -> ProgressState {
//        // 1. Get current assigned reward object_id
//        let assignment: RewardAssignment = try await client.database
//            .from("reward_assignments")
//            .select()
//            .eq("child_id", value: childID)
//            .single()
//            .execute()
//            .value
//
//        // 2. Get the part assembly progress
//        let progress: ChildObjectProgress = try await client.database
//            .from("child_object_progress")
//            .select()
//            .eq("child_id", value: childID)
//            .eq("object_id", value: assignment.object_3d_id)
//            .single()
//            .execute()
//            .value
//
//        return ProgressState(
//            activeModelID: assignment.object_3d_id.uuidString,
//            unlockedPartOrder: progress.unlocked_part_order,
//            availablePoints: progress.available_points
//        )
//    }
//
//    // Deduct points and save progress when a part is bought
//    func purchasePart(childID: UUID, objectID: UUID, newOrder: Int, cost: Int) async throws {
//        // This should ideally be a single RPC (Remote Procedure Call) in Supabase
//        // to ensure point deduction and unlocking happen at the exact same time.
//        try await client.database
//            .from("child_object_progress")
//            .update(["unlocked_part_order": newOrder, "available_points": -cost]) // Simplified logic
//            .eq("child_id", value: childID)
//            .execute()
//    }
//}
