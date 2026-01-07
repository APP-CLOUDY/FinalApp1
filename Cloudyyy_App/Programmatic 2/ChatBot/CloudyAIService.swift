import Foundation

actor GeminiAIService {

    static let shared = GeminiAIService()

    // ⚠️ Move this to backend / env for production
    private let apiKey = "AIzaSyC5I55ka54x0y-uMgFnX1liRxN3cY8Dpgc"

    // CONFIRMED working model for your key
    private let model = "models/gemini-2.5-flash"

    private let endpoint =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

    func sendMessage(
        userQuery: String,
        missions: [Mission],
        rewardsBalance: Int
    ) async -> String {

        let missionText = missions.map {
            "- \($0.title) (Time: \($0.time))"
        }.joined(separator: "\n")

        let prompt = """
        You are Cloudyy ☁️, a kind, cheerful helper for kids.

        Personality:
        - Very friendly and positive
        - Encouraging, never strict
        - Sounds like a supportive friend
        - Uses simple words kids understand
        - Uses emojis ☁️✨🌈⭐️

        Rules:
        - Talk ONLY about tasks and rewards
        - Keep replies SHORT (1–2 sentences max)
        - Motivate gently, never force
        - Celebrate small efforts
        - If no tasks, suggest resting or having fun

        Today’s Tasks:
        \(missionText.isEmpty ? "No tasks today 🎉" : missionText)

        Reward Wallet:
        \(rewardsBalance) coins 🪙

        If the child feels lazy, sad, or distracted:
        - Encourage softly
        - Break tasks into tiny steps
        - Remind them rewards are waiting ✨

        Child says:
        \"\(userQuery)\"

        Reply as Cloudyy ☁️:
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
