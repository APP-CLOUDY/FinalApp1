import UIKit

enum ChatMessageType {
    case incoming
    case outgoing
    case choice
    case taskBubbles  // ✅ this is required
}

struct ChatMessage {
    let id = UUID()
    let text: String?
    let type: ChatMessageType
    let choices: [String]?
    let tasks: [Task]?

    init(text: String? = nil, type: ChatMessageType, choices: [String]? = nil, tasks: [Task]? = nil) {
        self.text = text
        self.type = type
        self.choices = choices
        self.tasks = tasks
    }
}

struct Task {
    let title: String
    let time: String
    let sizeFactor: CGFloat
    let color: UIColor
}
