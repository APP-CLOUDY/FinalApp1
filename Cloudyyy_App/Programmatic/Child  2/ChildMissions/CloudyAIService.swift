//import Foundation
//
//// MARK: - AI Models (Same as before)
//struct ChatMessage: Identifiable, Equatable {
//    let id = UUID()
//    let text: String
//    let isUser: Bool // true = Child, false = AI
//    let timestamp = Date()
//}
//
//// MARK: - Gemini AI Service
//actor CloudyAIService {
//    static let shared = CloudyAIService()
//    
//    // ⚠️ REPLACE WITH YOUR ACTUAL GOOGLE GEMINI API KEY
//    private let apiKey = ""
//    
//    // Using Gemini 1.5 Flash (Fast & Efficient)
//    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
//    
//    func sendMessage(userQuery: String, missions: [Mission], rewardsBalance: Int) async throws -> String {
//        
//        // 1. Prepare Context Data
//        let missionContext = missions.map {
//            "- Task: \($0.title) (Time: \($0.time), Needs Photo Proof: \($0.requiresPhoto ? "Yes" : "No"))"
//        }.joined(separator: "\n")
//        
//        // 2. The System Instruction (The Brain)
//        // We tell Gemini explicitly who it is and what it knows.
//        let systemPrompt = """
//        ROLE: You are 'Cloudyy', a friendly, encouraging cloud character in a kids' app.
//        
//        CURRENT CHILD DATA:
//        \(missionContext)
//        - Current Wallet Balance: \(rewardsBalance) Coins
//        
//        STRICT RULES:
//        1. YOU MUST ONLY answer questions about the specific tasks and rewards listed above.
//        2. If the child asks about anything else (Math, History, Life, Coding), you MUST refuse politely. Say: "I'm just a cloud! I only know about your missions! ☁️"
//        3. Keep answers very short (max 2 sentences).
//        4. Use emojis (☁️, ✨, 🌟).
//        5. Be enthusiastic and supportive.
//        """
//        
//        // 3. Construct Gemini JSON Payload
//        // Gemini expects: { "systemInstruction": {...}, "contents": [...] }
//        let body: [String: Any] = [
//            "systemInstruction": [
//                "parts": [
//                    ["text": systemPrompt]
//                ]
//            ],
//            "contents": [
//                [
//                    "role": "user",
//                    "parts": [
//                        ["text": userQuery]
//                    ]
//                ]
//            ],
//            "generationConfig": [
//                "temperature": 0.7,
//                "maxOutputTokens": 100
//            ]
//        ]
//        
//        // 4. Build Request
//        guard let url = URL(string: "\(endpoint)?key=\(apiKey)") else { return "Error URL" }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        
//        // 5. Fire Network Call
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        // Debugging: Print error if status code isn't 200
//        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
//            print("Gemini API Error Code: \(httpResponse.statusCode)")
//            if let errorText = String(data: data, encoding: .utf8) {
//                print("Gemini Error Body: \(errorText)")
//            }
//            return "My cloud signal is fuzzy! (API Error)"
//        }
//        
//        // 6. Parse Gemini Response
//        // Structure: candidates[0] -> content -> parts[0] -> text
//        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//           let candidates = json["candidates"] as? [[String: Any]],
//           let firstCandidate = candidates.first,
//           let content = firstCandidate["content"] as? [String: Any],
//           let parts = content["parts"] as? [[String: Any]],
//           let text = parts.first?["text"] as? String {
//            
//            // Clean up response (Gemini sometimes adds extra newlines)
//            return text.trimmingCharacters(in: .whitespacesAndNewlines)
//        }
//        
//        return "Oops! I couldn't understand that. ☁️"
//    }
//}
