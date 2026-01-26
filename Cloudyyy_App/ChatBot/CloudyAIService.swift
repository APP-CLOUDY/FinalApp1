import Foundation

actor GeminiAIService {

    static let shared = GeminiAIService()

    // ⚠️ Move this to backend / env for production
    private let apiKey = "AIzaSyBHYhHoMvnQkXQNo9JaOQxveO0I6_vddM8"

    // CONFIRMED working model for your key (As per your request)
    private let model = "models/gemini-2.5-flash"

    private let endpoint =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

    // ✅ UPDATED: Now accepts 'rewardsList' to handle the Shop context
    func sendMessage(
        userQuery: String,
        missions: [Mission],
        rewardsList: [RewardItem], // 👈 Added this parameter
        rewardsBalance: Int
    ) async -> String {

        // 1. Format Tasks
        let missionText = missions.map {
            "- \($0.title) (Time: \($0.time))"
        }.joined(separator: "\n")
        
        // 2. Format Rewards (The Shop) 👈 NEW
        let shopText = rewardsList.map {
            "- \($0.title): \($0.points) ⭐️"
        }.joined(separator: "\n")

        // 3. Updated Prompt with Shop Context
        let prompt = """
        You are Cloudyy ☁️, a friendly assistant for kids.

        Context:
        - Wallet Balance: \(rewardsBalance) ⭐️ (Stars/Coins)
        
        - Today's Tasks:
        \(missionText.isEmpty ? "No tasks today." : missionText)
        
        - Rewards Shop (Things they can buy):
        \(shopText.isEmpty ? "Shop is empty." : shopText)

        Rules:
        - Only talk about tasks, rewards, and the shop.
        - If they ask "What can I buy?", list items from the Rewards Shop they can afford.
        - Keep replies short (max 2 sentences).
        - Use emojis ☁️✨.

        User says:
        \(userQuery)
        """

        let urlString = "\(endpoint)?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return fallback
        }

        let body: [String: Any] = [
            "contents": [
                [
                    "role": "user",
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard
                let http = response as? HTTPURLResponse,
                http.statusCode == 200
            else {
                return fallback
            }

            if
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let candidates = json["candidates"] as? [[String: Any]],
                let content = candidates.first?["content"] as? [String: Any],
                let parts = content["parts"] as? [[String: Any]],
                let text = parts.first?["text"] as? String
            {
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            return fallback

        } catch {
            print("❌ Gemini Network Error:", error)
            return fallback
        }
    }

    private var fallback: String {
        "My cloud signal is weak… try again later ☁️"
    }
}
