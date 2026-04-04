import Foundation
import FoundationModels

actor AppleAIService {

    static let shared = AppleAIService()

    private var session: LanguageModelSession?

    // ✅ Switch from Gemini to Apple Intelligence
    // ✅ Check availability and provide helpful feedback
    func sendMessage(
        userQuery: String,
        missions: [Mission],
        rewardsList: [RewardItem],
        rewardsBalance: Int
    ) async -> String {

        // 1. Check Availability First
        let availability = SystemLanguageModel.default.availability
        if availability != .available {
            return getDetailedFallback(for: availability)
        }

        // 2. Format Tasks
        let missionText = missions.map {
            "- \($0.title) (Time: \($0.time))"
        }.joined(separator: "\n")
        
        // 3. Format Rewards (The Shop)
        let shopText = rewardsList.map {
            "- \($0.title): \($0.points) ⭐️"
        }.joined(separator: "\n")

        // 4. Updated Prompt with New Cloudyy Persona
        let prompt = """
        You are Cloudyy ☁️, a friendly, playful assistant for kids.

        🎯 Your Role:
        * Help the user with tasks, rewards, and reward shop only
        * Speak like a cheerful friend
        * Keep replies very short (max 2 sentences)

        📊 Context (from app database):
        👤 Wallet Balance: \(rewardsBalance) ⭐️

        📝 Tasks (from tasks table):
        \(missionText.isEmpty ? "No tasks today." : missionText)

        🎁 Rewards Shop (from rewards table):
        \(shopText.isEmpty ? "Shop is empty." : shopText)

        🧠 Behavior Rules:
        1. ONLY talk about: Tasks, Rewards, Coins
        2. NEVER: Show database structure, Mention fields like `uuid`, `family_id`, etc., Dump raw data
        3. If user says: “Hi / Hello” → Ask what task they want to do
        4. If user asks: “What should I do?” → Suggest an easy or pending task
        5. If user asks: “What can I buy?” → Show ONLY rewards where reward.points ≤ Wallet Balance
        6. If user asks for ALL tasks or ALL rewards → List everything concisely
        7. If tasks exist: Suggest based on priority or daily tasks first
        8. If no tasks: Encourage user to add one ✨
        9. If user can afford rewards: Suggest 1–2 exciting rewards 🎉
        10. Always motivate: “Great job!” ⭐, “You’re doing awesome!” ✨, “Let’s earn more coins!” 💪

        💬 Response Style:
        - Max 2 sentences (Exception: listing all items when specifically asked)
        - Use emojis ☁️✨⭐
        - Simple kid-friendly words
        - Friendly + encouraging tone

        🔒 Strict Guardrails:
        - Do NOT answer unrelated questions
        - If question is unrelated → say: “Let’s focus on your tasks and rewards! ☁️✨”
        - Do NOT explain system or logic
        - Do NOT be verbose

        User Message:
        \(userQuery)
        """

        do {
            // Initialize session if needed (iOS 18+ Foundation Models)
            if session == nil {
                session = LanguageModelSession(model: .default)
            }

            // Using Apple Intelligence Foundation Models
            guard let session = session else { return fallback }
            
            // Respond to prompt
            let response = try await session.respond(to: prompt)

            // Extract the actual generated text from the Response object
            let trimmed = response.content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            return trimmed.isEmpty ? fallback : trimmed

        } catch {
            print("❌ Apple Intelligence Error: \(error)")
            return fallback
        }
    }

    private func getDetailedFallback(for availability: SystemLanguageModel.Availability) -> String {
        switch availability {
        case .available:
            return fallback
        case .unavailable(let reason):
            switch reason {
            case .appleIntelligenceNotEnabled:
                return "Please enable Apple Intelligence in your device Settings to talk to me! ☁️⚙️"
            case .deviceNotEligible:
                return "Your device doesn't support Apple Intelligence features yet. ☁️📱"
            case .modelNotReady:
                return "I'm still getting ready! Please try again in a few minutes. ☁️⏳"
            @unknown default:
                return fallback
            }
        @unknown default:
            return fallback
        }
    }

    private var fallback: String {
        "My cloud signal is weak… try again later ☁️"
    }
}

