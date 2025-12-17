import Foundation

actor OllamaAIService {

    static let shared = OllamaAIService()

    private let endpoint = "http://localhost:11434/api/generate"
    private let model = "llama3"

    func sendMessage(
        userQuery: String,
        missions: [Mission],
        rewardsBalance: Int
    ) async -> String {

        let missionText = missions.map {
            "- \($0.title) (Time: \($0.time))"
        }.joined(separator: "\n")

        let prompt = """
        You are Cloudyy ☁️, a friendly assistant for kids.

        Rules:
        - Only talk about tasks and rewards
        - Keep replies short (max 2 sentences)
        - Use emojis ☁️✨

        Tasks:
        \(missionText.isEmpty ? "No tasks today." : missionText)

        Wallet: \(rewardsBalance) coins

        User says:
        \(userQuery)
        """

        let body: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "stream": false
        ]

        guard let url = URL(string: endpoint) else {
            return fallback
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                print("❌ Ollama HTTP Error:", http.statusCode)
                print(String(data: data, encoding: .utf8) ?? "")
                return fallback
            }

            if
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let text = json["response"] as? String
            {
                return text.trimmingCharacters(in: .whitespacesAndNewlines)
            }

            return fallback

        } catch {
            print("❌ Ollama Network Error:", error)
            return fallback
        }
    }

    private var fallback: String {
        "My cloud signal is weak… try again later ☁️"
    }
}
