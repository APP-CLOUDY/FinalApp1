import Foundation

actor SimpleCloudyAIService {
    static let shared = SimpleCloudyAIService()

    func sendMessage(
        userQuery: String,
        missions: [Mission],
        rewardsBalance: Int
    ) async -> String {

        let lower = userQuery.lowercased()

        if lower.contains("task") || lower.contains("mission") {
            if missions.isEmpty {
                return "You have no tasks right now ☁️✨"
            } else {
                return "You have \(missions.count) missions today! Tap a bubble to start ☁️✨"
            }
        }

        if lower.contains("reward") || lower.contains("coin") {
            return "You have \(rewardsBalance) coins! Keep going ☁️✨"
        }

        if lower.contains("hello") || lower.contains("hi") {
            return "Hi! I’m Cloudyy ☁️ Ready for your missions?"
        }

        return "I can help with tasks and rewards ☁️✨"
    }
}
